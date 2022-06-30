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
  var result:[UserContactModel] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.bar.alpha = 0
    
    CNContactStore().requestAccess(for: .contacts) { (isRight, error) in
      if isRight {
        //授权成功加载数据。
        self.loadContactsData()
      }else {
        AlertView.show(message: "You need to get permission for your mobile phone address book")
      }
    }
  }
  
  
  func loadContactsData() {
    //获取授权状态
    let status = CNContactStore.authorizationStatus(for: .contacts)
    //判断当前授权状态
    guard status == .authorized else { return }
    
    //创建通讯录对象
    let store = CNContactStore()
    
    //获取Fetch,并且指定要获取联系人中的什么属性
    let keys = [CNContactFamilyNameKey,
                CNContactGivenNameKey,
                CNContactNicknameKey,
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey
    ]
    
    //创建请求对象
    //需要传入一个(keysToFetch: [CNKeyDescriptor]) 包含CNKeyDescriptor类型的数组
    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
    
    
    //遍历所有联系人
    do {
      try store.enumerateContacts(with: request, usingBlock: {
        (contact : CNContact, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
        
        //获取姓名
        let lastName = contact.familyName
        let firstName = contact.givenName
        let name = lastName + firstName
        print("姓名：\(lastName)\(firstName)")
        
        //获取昵称
        let nikeName = contact.nickname
        print("昵称：\(nikeName)")
       
        //获取电话号码
        print("电话：")
        
        var models:[UserContactModel] = []
        for phone in contact.phoneNumbers {
          //获得标签名（转为能看得懂的本地标签名，比如work、home）
          var label = "未知标签"
          if phone.label != nil {
            label = CNLabeledValue<NSString>.localizedString(forLabel:
                                                              phone.label!)
          }
          
          //获取号码
          let value = phone.value.stringValue.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+65", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
          let model = UserContactModel(name:name,phone: value)
          models.append(model)
          self.result.append(model)
          print("\t\(label)：\(value)")
        }
        
        print("----------------")
        
      })
    } catch {
      print(error)
    }
  }
  
  func matchPhone() {
    let params = SOAPParams(action: .Client, path: .matchPhone)
    
    let data = SOAPDictionary()
    self.result.enumerated().forEach({ i,e in
      data.set(key: i.string, value: e.phone)
    })
    
    params.set(key: "data", value: data.result, type: .map(1))
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(MatchPhoneModel.self, from: data) {
        
        self.result.forEach { e in
          models.forEach { me in
            e.isAdd = me.phone == e.phone
            e.id = me.id ?? ""
          }
        }
        self.dataArray = self.result
        self.endRefresh(self.dataArray.count,emptyString: "Contact not found")
      }
    } errorHandler: { e in
      
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
      self.result = self.result.filter({
        ($0.name == text) || ($0.phone == text)
      })
      self.matchPhone()
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
      cell.model = self.dataArray[indexPath.row] as? UserContactModel
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = self.dataArray[indexPath.row] as! UserContactModel
    if model.isAdd {
      AlertView.show(title: "Are you sure you want to add this user?", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Yes") {
        
      } rightHandler: {
        self.addUserToWallet(model)
      } dismissHandler: {
        
      }
    }else {
      let vc = ReferFriendController()
      self.navigationController?.pushViewController(vc)
    }
    
  }
  
  func addUserToWallet(_ model:UserContactModel) {
    let params = SOAPParams(action: .Voucher, path: .saveCardFriend)
    
    let data = SOAPDictionary()
    data.set(key: "card_owner_id", value: Defaults.shared.get(for: .clientId) ?? "")
    data.set(key: "friend_id", value: model.id)
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
  
  func addUserNotification(_ model:UserContactModel) {
    let params = SOAPParams(action: .Notifications, path: .addUserInWallet)
    
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "friendId", value: model.id)
    
    NetworkManager().request(params: params) { data in
      self.navigationController?.popViewController()
    } errorHandler: { e in
      self.navigationController?.popViewController()
    }

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
  
  var model:UserContactModel? {
    didSet {
      nameLabel.text = model?.name
      phoneLabel.text = model?.phone
      inviteLabel.text = (model?.isAdd ?? false) ? "Add" : "Invite"
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
