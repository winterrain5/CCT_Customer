//
//  WalletDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/4.
//

import UIKit
import PromiseKit
class WalletDetailController: BaseTableController {
  var headerView = WalletDetailHeadView.loadViewFromNib()
  var footerView = WalletDetailFooterView()
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Wallet Details"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadNewData()
  }
  
  override func refreshData() {
    getClientPartInfo()
    getNewReCardAmount()
    
    firstly {
      getCardFriends()
    }.then { models1 -> Promise<[CardOwnerModel]> in
      self.dataArray.append(models1)
      return self.getFriendCard()
    }.done { models2 in
      self.dataArray.append(models2)
      self.endRefresh()
    }.catch { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
    }
  }
  
  func getClientPartInfo() {
    
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        
        self.headerView.card.model = model
        self.getNewCardDiscountsByLevel(model.new_recharge_card_level)
      }else {
        Toast.showError(withStatus: "decode UserModel Failed")
      }
    } errorHandler: { e in
      
    }
  }
  
  func getNewReCardAmount() {
    
    let params = SOAPParams(action: .Voucher, path: .getNewReCardAmountByClientId)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      self.headerView.card.money = String(data: data, encoding: .utf8)?.formatMoney().dolar ?? ""
    } errorHandler: { e in
      
    }
  }
  
  func getNewCardDiscountsByLevel(_ level:String) {
    let l = (level == "0") ? "1" : level
   
    let params = SOAPParams(action: .CardDiscountContent, path: .getCardDiscountDetails)

    params.set(key: "levelId", value: l)
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeByCodable(CardDiscountDetailModel.self, from: data) {
        self.headerView.model = model
      }
    } errorHandler: { e in
      
    }
    
  }
  
  /// 朋友的卡 可进行支付
  func getFriendCard() -> Promise<[CardOwnerModel]>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Voucher, path: .getFriendsCard)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(CardOwnerModel.self, from: data) {
          models.forEach({ $0.isFriendCard = true })
          resolver.fulfill(models)
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "decode CardOwnerModel failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  /// 谁绑了我的卡
  func getCardFriends() -> Promise<[CardOwnerModel]>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Voucher, path: .getCardFriends)
      params.set(key: "ownerId", value: Defaults.shared.get(for: .clientId) ?? "")
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(CardOwnerModel.self, from: data) {
          models.forEach({ $0.isFriendCard = false })
          resolver.fulfill(models)
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "decode CardOwnerModel failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  
  override func createListView() {
    super.createListView()
    tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: 353)
    headerView.updateHeightHandler = { [weak self] height in
      self?.headerView.height = height
      self?.tableView?.tableHeaderView = self?.headerView
    }
    
    tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 60)
    
    tableView?.register(nibWithCellClass: WalletDetailCardUserOrOwenrCell.self)
    
    registRefreshHeader()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.dataArray.count > 0 {
      let models = self.dataArray[section] as? [CardOwnerModel]
      return models?.count ?? 0
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: WalletDetailCardUserOrOwenrCell.self)
    if self.dataArray.count > 0 {
      let models = self.dataArray[indexPath.section] as? [CardOwnerModel]
      let model = models?[indexPath.row]
      if model?.isFriendCard ?? false {
        cell.type = .Owner
        cell.removeHandler = { [weak self] model in
          AlertView.show(title: "", message: "Are you sure want to remove this item", leftButtonTitle: "Cancel", rightButtonTitle: "Yes", messageAlignment: .center) {
            
          } rightHandler: {
            self?.deleteCardFriend(model.id ?? "",model.card_owner_id ?? "")
          } dismissHandler: {
            
          }

        }
      }else {
        cell.type = .User
      }
      cell.model = model
    }
    
    return cell
  }
  
  func deleteCardFriend(_ id:String,_ friendId:String) {
    Toast.showLoading()
    
    let params = SOAPParams(action: .Voucher, path: .deleteCardFriend)
    params.set(key: "id", value: id)
    
    let logData = SOAPDictionary()
    logData.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
    params.set(key: "logData", value: logData.result,type: .map(1))
    
    NetworkManager().request(params: params) { data in
      self.deleteUserFromWallet(friendId)
    } errorHandler: { e in
      Toast.showError(withStatus: "Removed Failed")
    }

    
  }
  
  func deleteUserFromWallet(_ friendId:String) {
    let params = SOAPParams(action: .Notifications, path: .deleteUserFromWallet)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "friendId", value: friendId)
    
    NetworkManager().request(params: params) { data in
      self.loadNewData()
      Toast.showSuccess(withStatus: "Removed Successfully")
    } errorHandler: { e in
      Toast.showSuccess(withStatus: "Removed Successfully")
    }

  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = WalletDetailSectionView()
    let models = self.dataArray[section] as? [CardOwnerModel]
    if section == 0 {
      view.type = .User
      view.isHaveCardUsers = (models?.count ?? 0) > 0
    }else {
      view.type = .Owner
    }
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if self.dataArray.count > 0 {
      let models = self.dataArray[section] as? [CardOwnerModel]
      if section == 0 {
        if (models?.count ?? 0 > 0)  {
          return 52
        }else {
          return 102
        }
      } else {
        if models?.count ?? 0 > 0 {
          return 52
        }
        return 0
      }
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.section == 0 {
      let models = self.dataArray[indexPath.section] as! [CardOwnerModel]
      if models.count > 0 {
        let vc = CardUserDetailController(cardUserModel: models[indexPath.row])
        self.navigationController?.pushViewController(vc)
      }
      
    }
  }
}


class WalletDetailSectionView:UIView {
  var label = UILabel().then { label in
    label.text = "Card Users"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:18)
  }
  lazy var addButton = UIButton().then { btn in
    btn.titleForNormal = "+ Add Users"
    btn.titleColorForNormal = R.color.theamRed()
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.contentHorizontalAlignment = .right
    btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
  }
  var descLabel = UILabel().then { label in
    label.text = "You have not shared your card with your loved ones"
    label.textColor = R.color.black333()
    label.font = UIFont(name:.AvenirNextRegular,size:14)
    label.numberOfLines = 0
  }
  var type:CardBelongType = .User {
    didSet {
      if type == .Owner {
        label.text = "Card Owner"
        addButton.isHidden = true
        descLabel.isHidden = true
      }else{
        label.text = "Card Users"
        descLabel.isHidden = false
        addButton.isHidden = false
      }
    }
  }
  var isHaveCardUsers:Bool = true {
    didSet {
      descLabel.isHidden = isHaveCardUsers
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(label)
    addSubview(addButton)
    addSubview(descLabel)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  @objc func addAction() {
    let vc = WalletAddUserController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(16)
    }
    addButton.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(24)
      make.width.equalTo(kScreenWidth - 24)
      make.centerY.equalTo(label)
    }
    descLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalTo(label.snp.bottom).offset(16)
    }
  }
}

class WalletDetailFooterView: UIView {

  var lineView = UIView().then { view in
    view.backgroundColor = R.color.line()
  }
  var label = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:18)
  }
  lazy var arrowButton = UIButton().then { btn in
    btn.contentHorizontalAlignment = .right
    btn.addTarget(self, action: #selector(arrowButtonAction), for: .touchUpInside)
  }
  
  init(title:String = "Terms and Conditions",isNeedArrow:Bool = true) {
    super.init(frame:.zero)
    
    addSubview(lineView)
    addSubview(label)
    addSubview(arrowButton)
    
    label.text = title
    if isNeedArrow {
      arrowButton.imageForNormal = R.image.account_arrow_right()
    }
  }
  

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }

  
  override func layoutSubviews() {
    super.layoutSubviews()
    lineView.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
      make.height.equalTo(1)
    }
    label.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalToSuperview()
    }
    arrowButton.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(24)
      make.top.bottom.equalToSuperview()
      make.width.equalTo(kScreenWidth - 24)
    }
  }
  
  @objc func arrowButtonAction() {
    WalletTermsConditionsSheetView.show()
  }
}
