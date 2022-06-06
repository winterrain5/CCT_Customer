//
//  ProfileViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/29.
//

import UIKit
import SideMenuSwift
class ProfileActionModel {
  var image: UIImage?
  var title: String = ""
  var sel: String = ""
  var isLogout = false
  init(image: UIImage? = nil, title: String, sel: String,isLogout:Bool = false) {
    self.image = image
    self.title = title
    self.sel = sel
    self.isLogout = isLogout
  }
}


class ProfileViewController: BaseTableController {
  
  private var headView = ProfileHeadView.loadViewFromNib()
  private var actions:[[ProfileActionModel]] = [
    [ProfileActionModel(image: R.image.profile_wallet(), title: "My Wallet", sel: "myWallet"),
     ProfileActionModel(image: R.image.profile_transaction_history(), title: "Transaction History", sel: "transactionHistory"),
     ProfileActionModel(image: R.image.profile_my_orders(), title: "My Orders", sel: "myOrders"),
     ProfileActionModel(image: R.image.profile_refer_to_friend(), title: "Refer To a Friend", sel: "referToFriend")],
    [ProfileActionModel(image: R.image.profile_account_manager(), title: "Acount Management", sel: "acountManagement"),
     ProfileActionModel(image: R.image.profile_contact_us(), title: "Contact Us", sel: "contactUs"),
     ProfileActionModel(image: R.image.profile_settings(), title: "Settings", sel: "settings"),
     ProfileActionModel(image: R.image.profile_questions(), title: "Frequently Asked Questions", sel: "frequentlyAskedQuestions")],
    [ProfileActionModel(image: R.image.profile_logout(), title: "Logout", sel: "logout")]
  ]
  private var sectionTitles = ["References","Account & Support",""]
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Profile"
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: nil, backButtonTitle: nil)
    self.navigation.item.leftBarButtonItem = UIBarButtonItem(image: R.image.notification_menu(), style: .plain, target: self, action: #selector(leftItemAction))
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.refreshData()
  }
  override func refreshData() {
    getNewReCardAmount()
    if let model = Defaults.shared.get(for: .userModel) {
      headView.model = model
    }else {
      
      let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
          Defaults.shared.set(model, for: .userModel)
          self.headView.model = model
        }
      } errorHandler: { e in
        
      }
    }
  }
  
  
  func getNewReCardAmount() {
    
    let params = SOAPParams(action: .Voucher, path: .getNewReCardAmountByClientId)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      self.headView.money = String(data: data, encoding: .utf8)?.formatMoney().dolar ?? ""
    } errorHandler: { e in
      
    }
  }
  
  override func createListView() {
    super.createListView()
    
    self.tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: 152)
    
    self.tableView?.register(cellWithClass: UITableViewCell.self)
    
    registRefreshHeader()
  }
  
  override func listViewFrame() -> CGRect {
    return CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kTabBarHeight)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 56
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return actions.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return actions[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
    cell.textLabel?.font = UIFont(name:.AvenirNextRegular,size:16)
    cell.textLabel?.textColor = .black
    cell.textLabel?.text = actions[indexPath.section][indexPath.row].title
    cell.imageView?.image = actions[indexPath.section][indexPath.row].image
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 2 ? 16 : 48
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return ProfileSectionView(text: sectionTitles[section])
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let selStr = actions[indexPath.section][indexPath.row].sel
    let sel = NSSelectorFromString(selStr)
    if self.responds(to: sel) {
      self.perform(sel)
    }
  }

}

extension ProfileViewController {
  
  @objc func leftItemAction() {
    sideMenuController?.revealMenu()
  }
  @objc func transactionHistory() {
    let vc = MyWalletController(defautIndex: 1)
    self.navigationController?.pushViewController(vc)
  }

 
  @objc func acountManagement() {
    let vc = AccountManagementController()
    self.navigationController?.pushViewController(vc)
  }
  
  @objc func settings() {
    let vc = SettingViewController()
    self.navigationController?.pushViewController(vc)
  }
 
  @objc func logout() {
    AlertView.show(title: "Are you sure you want to logout from your account", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Confirm", messageAlignment: .center, leftHandler: nil) {
      Defaults.shared.removeAll()
      let vc = LoginViewController()
      let nav = BaseNavigationController(rootViewController: vc)
      UIApplication.shared.keyWindow?.rootViewController = nav
    } dismissHandler: {
      
    }
  }
  
}

class ProfileSectionView:UIView {
  var label = UILabel().then { label in
    label.textColor = R.color.gray82()
    label.font = UIFont(name:.AvenirNextRegular,size:12)
  }
  
  convenience init(text:String) {
    self.init()
    addSubview(label)
    label.text = text
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalToSuperview()
    }
  }
}

