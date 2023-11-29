//
//  WalletAddUserController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/9.
//

import UIKit
import Contacts

class WalletAddUserController: BaseTableController {
  
  var headView = WalletAddUserHeadView.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.bar.alpha = 0
 
  }
  
  
  
  func getClientByPhone(_ phone:String) {
    let params = SOAPParams(action: .Client, path: .getClientsByPhone)
    
    params.set(key: "phone", value: phone)
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(MatchPhoneModel.self, from: data) {
        self.dataArray = models
        self.endRefresh(self.dataArray.count,emptyString: "Contact not found")
      }
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
    }

  }
  
  
  override func createListView() {
    super.createListView()
    
    tableView?.separatorColor = R.color.line()
    tableView?.separatorStyle = .singleLine
    tableView?.separatorInset = .zero
    
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: kNavBarHeight + 270)
    headView.endEditHandler = { [weak self] text in
      guard let `self` = self else { return }
      self.getClientByPhone(text)
    }
    
    tableView?.register(cellWithClass: WalletInviteUserCell.self)
  }
  
  override func listViewFrame() -> CGRect {
    return self.view.bounds
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 68
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: WalletInviteUserCell.self)
    if self.dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? MatchPhoneModel
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = self.dataArray[indexPath.row] as! MatchPhoneModel
    
    WalletAddUserSheetView.show(fromView: self.view) { text in
      self.addUserToWallet(model,text)
    }
  }
  
  func addUserToWallet(_ model:MatchPhoneModel,_ remark:String) {
    let params = SOAPParams(action: .Voucher, path: .saveCardFriend)
    
    let data = SOAPDictionary()
    data.set(key: "card_owner_id", value: Defaults.shared.get(for: .clientId) ?? "")
    data.set(key: "owner_remark", value: remark)
    data.set(key: "friend_id", value: model.id ?? "")
    data.set(key: "trans_limit", value: -1)
    
    params.set(key: "data", value: data.result,type: .map(1))
    
    let logData = SOAPDictionary()
    logData.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
    
    params.set(key: "logData", value: logData.result,type: .map(1))
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.showSuccess(withStatus: "Add Successfully")
      self.addUserNotification(model)
    } errorHandler: { e in
      Toast.showError(withStatus: "Add Failed")
    }

  }
  
  func addUserNotification(_ model:MatchPhoneModel) {
    let params = SOAPParams(action: .Notifications, path: .cardNotice)
    
    params.set(key: "ownerId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "gainerId", value: model.id ?? "")
    
    NetworkManager().request(params: params) { data in
      self.navigationController?.popViewController()
    } errorHandler: { e in
      self.navigationController?.popViewController()
    }

  }
  
  func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
    return -(kNavBarHeight + 270) * 0.5
  }
  
}


class WalletInviteUserCell:UITableViewCell {
  var phoneLabel = UILabel().then { label in
    label.textColor = R.color.gray82()
    label.font = UIFont(name:.AvenirNextRegular,size:14)
  }
  var nameLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size:16)
  }
  var inviteLabel = UILabel().then { label in
    label.textColor = R.color.theamRed()
    label.font = UIFont(name: .AvenirNextDemiBold, size:14)
    label.text = "Invite"
  }
  
  var model:MatchPhoneModel? {
    didSet {
      nameLabel.text = "New E-Wallet User"
      phoneLabel.text = model?.mobile
      inviteLabel.text = "Add"
    }
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(phoneLabel)
    contentView.addSubview(inviteLabel)
    contentView.addSubview(nameLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    nameLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(12)
    }
    inviteLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalToSuperview()
    }
    phoneLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.bottom.equalToSuperview().offset(-12)
    }
  }
}
