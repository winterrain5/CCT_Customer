//
//  WalletPaymentMethodController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit

class WalletPaymentMethodController: BaseTableController {
  var cardModel:WalletPaymentMethodModel?
  var selectIndex:IndexPath?
  lazy var headLabel = UILabel().then { label in
    label.text = "Payment Method"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:18)
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
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
  }
  
  lazy var addButton = UIButton().then { btn in
    
    btn.backgroundColor = .white
    btn.titleForNormal = "Add Card"
    btn.titleColorForNormal = R.color.theamRed()
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.addTarget(self, action: #selector(addCardAction), for: .touchUpInside)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Payment Method"
    
    refreshData()
    
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .PaymentMethod, path: .getMethodsForApp)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(WalletPaymentMethodModel.self, from: data),let methods = models.first?.method_lines {
        self.cardModel = models.first
        
        if methods.count != 0 {
          if let selModel = Defaults.shared.get(for: .payMethodLine) {
            methods.enumerated().forEach { idx,item in
              if item.id == selModel.id {
                item.isSelected = true
                self.selectIndex = IndexPath(row: idx, section: 0)
              }
            }
          }
          
          self.dataArray = methods
          self.addHeadFootView()
        }else {
          self.removeHeadFootView()
        }
        self.endRefresh(methods.count,emptyString: "You have no payment Method")
        return
      }
      self.endRefresh()
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }

  }
  
  override func createListView() {
    super.createListView()
    tableView?.separatorStyle = .singleLine
    tableView?.separatorInset = .zero
    tableView?.separatorColor = R.color.line()
    tableView?.register(nibWithCellClass: WalletPaymentMethodCell.self)
    
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
      let model = self.dataArray[indexPath.row] as? MethodLines
      model?.type = 2
      cell.model = model
      cell.deleteHandler = { [weak self] model in
        self?.delete(model)
      }
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let sel = selectIndex {
      let model = self.dataArray[sel.row] as! MethodLines
      model.isSelected = false
      self.tableView?.reloadRows(at: [sel], with: .automatic)
    }
    
    let model = self.dataArray[indexPath.row] as! MethodLines
    model.isSelected = true
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
    if let sel = selectIndex {
      let model = self.dataArray[sel.row] as! MethodLines
      Defaults.shared.set(model, for: .payMethodLine)
      Defaults.shared.set(self.cardModel?.id ?? "", for: .payMethodId)
      self.navigationController?.popViewController()
    }else {
      Toast.showError(withStatus: "Please select Payment Method")
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


