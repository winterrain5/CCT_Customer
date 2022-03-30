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
  var result:[WalletInviteUserModel] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.bar.alpha = 0
    
    CNContactStore().requestAccess(for: .contacts) { (isRight, error) in
      if isRight {
        //授权成功加载数据。
        self.loadContactsData()
      }
    }
  }
  
  func searchClientsByFields(_ mobile:String) {
    let params = SOAPParams(action: .Client, path: .searchClientsByFields)
    
    let data = SOAPDictionary()
    data.set(key: "mobile", value: mobile)
    
    params.set(key: "searchData", value: data.result,type: .map(1))
    params.set(key: "ownerId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
  
    NetworkManager().request(params: params) { data in
      
    } errorHandler: { e in
      
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
        for phone in contact.phoneNumbers {
          //获得标签名（转为能看得懂的本地标签名，比如work、home）
          var label = "未知标签"
          if phone.label != nil {
            label = CNLabeledValue<NSString>.localizedString(forLabel:
                                                              phone.label!)
          }
          
          //获取号码
          let value = phone.value.stringValue
          let model = WalletInviteUserModel(name:name,phone: value)
          self.dataArray.append(model)
          print("\t\(label)：\(value)")
        }
        
        print("----------------")
        
      })
    } catch {
      print(error)
    }
  }
  
  
  
  override func createListView() {
    super.createListView()
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: kNavBarHeight + 270)
    headView.endEditHandler = { [weak self] text in
      guard let `self` = self else { return }
      self.result = (self.dataArray as! [WalletInviteUserModel]).filter({
        ($0.name == text) || ($0.phone == text)
      })
      self.reloadData()
    }
    
    tableView?.register(cellWithClass: WalletInviteUserCell.self)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return result.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: WalletInviteUserCell.self)
    if result.count > 0 {
      cell.model = result[indexPath.row]
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    AlertView.show(title: "Are you sure you want to invite this user?", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Yes") {
      
    } rightHandler: {
    
    } dismissHandler: {
      
    }

  }
  
  override func listViewFrame() -> CGRect {
    return self.view.bounds
  }
}


class WalletInviteUserCell:UITableViewCell {
  var valueLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(.AvenirNextDemiBold,16)
  }
  var inviteLabel = UILabel().then { label in
    label.textColor = R.color.theamRed()
    label.font = UIFont(.AvenirNextDemiBold,14)
    label.text = "Invite"
  }
  
  var model:WalletInviteUserModel? {
    didSet {
      valueLabel.text = "\(model?.name ?? "")(\(model?.phone ?? ""))"
    }
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(valueLabel)
    contentView.addSubview(inviteLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    valueLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalToSuperview()
    }
    inviteLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalToSuperview()
    }
  }
}
