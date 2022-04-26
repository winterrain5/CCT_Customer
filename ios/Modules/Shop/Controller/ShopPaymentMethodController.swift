//
//  ShopPaymentMethodController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/15.
//

import UIKit
import PromiseKit
class ShopPaymentMethodController: BaseTableController {

  var cardModel:WalletPaymentMethodModel?
  var selectIndex:IndexPath = IndexPath(row: 0, section: 0)
  lazy var headLabel = UILabel().then { label in
    label.text = "Select your Payment Method"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextDemiBold,18)
  }
  lazy var headView = UIView().then { view in
    view.backgroundColor = .white
    view.addSubview(headLabel)
    headLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(24)
    }
  }
  
  lazy var doneButton = UIButton().then { btn in
    
    btn.backgroundColor = R.color.theamRed()
    btn.titleForNormal = "Done"
    btn.cornerRadius = 22
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
  }
  
  lazy var addButton = UIButton().then { btn in
    
    btn.backgroundColor = .white
    btn.titleForNormal = "Add Card"
    btn.titleColorForNormal = R.color.theamRed()
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.addTarget(self, action: #selector(addCardAction), for: .touchUpInside)
    
  }
  var selectCompleteHandler:((MethodLines,WalletPaymentMethodModel)->())?
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Payment Method"
    
    self.refreshData()
    
    
  }
  
  override func refreshData() {
    firstly {
      self.getUserLevel()
    }.then {
      self.addUserAmount()
    }.then {
      self.getFriendCard()
    }.then {
      self.getCard()
    }.done {
      self.endRefresh()
    }.catch { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
    }
  }
  
  func getUserLevel() -> Promise<Void> {
    
    Promise.init { resolver in
      if let _ = Defaults.shared.get(for: .userModel) {
        resolver.fulfill_()
        return
      }
      let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
          Defaults.shared.set(model, for: .userModel)
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode UserModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  /// 获取自己的余额
  func addUserAmount() -> Promise<Void>{
    Promise.init { resolver in
      guard let user = Defaults.shared.get(for: .userModel) else { return }
      let model = MethodLines()
      
      let params = SOAPParams(action: .Voucher, path: .getNewReCardAmountByClientId)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      var level = ""
      if user.new_recharge_card_level == "0" || user.new_recharge_card_level == "1" {
        level = "Basic"
      }
      if user.new_recharge_card_level == "2" {
        level = "Silver"
      }
      if user.new_recharge_card_level == "3" {
        level = "Gold"
      }
      if user.new_recharge_card_level == "4" {
        level = "Platinum"
      }
      let levelName =  "CCT " + level + " Card"
      
      NetworkManager().request(params: params) { data in
        model.name_on_card = levelName
        model.amount = String(data: data, encoding: .utf8) ?? ""
        model.type = 0
        model.isSelected = true
        self.dataArray.append(model)
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
    

  }
  
  func getFriendCard() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Voucher, path: .getFriendsCard)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(CardOwnerModel.self, from: data) {
          models.forEach { e in
            let model = MethodLines()
            model.name_on_card = e.first_name?.appending(e.last_name ?? "")
            model.amount = e.new_card_amount?.string ?? "0"
            model.type = 1
            model.trans_limit = e.trans_limit ?? "0"
            model.card_owner_id = e.card_owner_id ?? ""
            self.dataArray.append(model)
          }
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode CardOwnerModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
    

  }
  
  func getCard() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .PaymentMethod, path: .getMethodsForApp)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(WalletPaymentMethodModel.self, from: data),let methods = models.first?.method_lines {
          self.cardModel = models.first
          methods.forEach({ $0.type = 2 })
          self.dataArray.append(contentsOf: methods)
            
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode WalletPaymentMethodModel Failed"))
        }
        
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
   
  }
  
  
  override func createListView() {
    super.createListView()
    tableView?.separatorStyle = .singleLine
    tableView?.separatorInset = .zero
    tableView?.separatorColor = R.color.line()
    tableView?.register(nibWithCellClass: WalletPaymentMethodCell.self)
    
    self.addHeadFootView()
  }
  
  func addHeadFootView() {
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: 60)
    
    view.addSubview(doneButton)
    view.addSubview(addButton)
    
    doneButton.snp.makeConstraints { make in
      make.height.equalTo(44)
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(kBottomsafeAreaMargin + 40)
    }
    addButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.width.equalTo(100)
      make.height.equalTo(40)
      make.bottom.equalTo(doneButton.snp.top).offset(-30)
    }
    
  }
  
  func removeHeadFootView() {
    tableView?.tableHeaderView = nil
    doneButton.removeFromSuperview()
    addButton.removeFromSuperview()
  }
  

  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 56
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: WalletPaymentMethodCell.self)
    if self.dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? MethodLines
      cell.deleteHandler = { [weak self] model in
        self?.delete(model)
      }
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let m1 = self.dataArray[selectIndex.row] as! MethodLines
    m1.isSelected = false
    self.tableView?.reloadRows(at: [selectIndex], with: .automatic)
    
    let m2 = self.dataArray[indexPath.row] as! MethodLines
    m2.isSelected = true
    self.tableView?.reloadRows(at: [indexPath], with: .automatic)
    
    
    selectIndex = indexPath
    
  }
  
  @objc func addCardAction() {
     let sheet = WalletAddCardSheetView()
    sheet.show(fromView: self.view)
    sheet.contentView.confirmHandler = { [weak self] result in
      guard let `self` = self else { return }
      result.button.startAnimation()
      let params = SOAPParams(action: .PaymentMethod, path: .addCardIntoPayment)
             let data = SOAPDictionary()
      data.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      data.set(key: "payment_method_id", value: self.cardModel?.id ?? "")
      data.set(key: "name_on_card", value: result.name)
      data.set(key: "card_number", value: result.number)
      data.set(key: "expiry_date", value: result.date)
      data.set(key: "authorisation_code", value: result.cvv)
      data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
                        
      params.set(key: "data", value: data.result,type: .map(1))
      
      result.button.startAnimation()
      NetworkManager().request(params: params) { data in
        result.button.stopAnimation()
        sheet.dismiss()
        self.loadNewData()
      } errorHandler: { e in
        sheet.dismiss()
        result.button.stopAnimation()
      }

    }
  }
  
  @objc func doneAction() {
    if let card = cardModel {
      let model = self.dataArray[selectIndex.row] as! MethodLines
      selectCompleteHandler?(model,card)
      self.navigationController?.popViewController()
    }else {
      Toast.showMessage("Error")
    }
  }
  
  func delete(_ model:MethodLines){
    AlertView.show(title: "Are you sure you want to remove this payment method?", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Confirm", messageAlignment: .center, leftHandler: nil, rightHandler: {
      let params = SOAPParams(action: .PaymentMethod, path: .deleteCardIntoPayment)
      params.set(key: "id", value: model.id ?? "")
      Toast.showLoading()
      NetworkManager().request(params: params) { data in
        if let savedMethod = Defaults.shared.get(for: .payMethodLine) {
          if savedMethod.id == model.id {
            Defaults.shared.clear(.payMethodLine)
            Defaults.shared.clear(.payMethodId)
          }
        }
        self.loadNewData()
        Toast.showSuccess(withStatus: "Delete Success")
      } errorHandler: { e in
        
      }
    }, dismissHandler: nil)
   
  }
  
  func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> UIImage! {
    return R.image.wallet_payment_no_data_button()
  }
  
  func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
    addCardAction()
  }

}
