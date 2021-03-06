//
//  MenuViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/10.
//

import UIKit
import SideMenuSwift
class MenuViewController: BaseTableController {
  let menuWidth = SideMenuController.preferences.basic.menuWidth
  let navVc =  UIViewController.getTopVc()?.navigationController
  private var headView = MenuHeadView()
  private var actions:[ProfileActionModel] = [
    ProfileActionModel(title: "Home", sel: "home"),
    ProfileActionModel(title: "CCT Wallet", sel: "myWallet"),
    ProfileActionModel(title: "Appointments", sel: "appointments"),
    ProfileActionModel(title: "Services", sel: "services"),
    ProfileActionModel(title: "Shop", sel: "shop"),
    ProfileActionModel(title: "My Orders", sel: "myOrders"),
    ProfileActionModel(title: "Symptom Checker", sel: "symptomChecker"),
    ProfileActionModel(title: "Conditions We Treat", sel: "conditionsWeTreat"),
    ProfileActionModel(title: "Blog", sel: "blog"),
    ProfileActionModel(title: "Madam Partum", sel: "madamPartum"),
    ProfileActionModel(title: "Bookmarks", sel: "bookmarks"),
    ProfileActionModel(title: "Refer a Friend", sel: "referToFriend"),
    ProfileActionModel(title: "Our Story", sel: "ourStory"),
    ProfileActionModel(title: "Contact Us", sel: "contactUs"),
    ProfileActionModel(title: "Frequently Asked Questions", sel: "frequentlyAskedQuestions")
  ]
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = R.color.theamBlue()
    tableView?.reloadData()
  }
  
  override func createListView() {
    super.createListView()
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: menuWidth, height: 120)
    tableView?.register(cellWithClass: UITableViewCell.self)
    tableView?.backgroundColor = .clear
  }
  
  override func listViewFrame() -> CGRect {
    return CGRect(x: kScreenWidth - menuWidth, y: 0, width: menuWidth, height: kScreenHeight)
  }
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 48
  }
  

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return actions.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
    cell.textLabel?.font = UIFont(name:.AvenirNextRegular,size:16)
    cell.textLabel?.textColor = .white
    cell.textLabel?.text = actions[indexPath.row].title
    cell.contentView.backgroundColor = .clear
    cell.backgroundColor = .clear
    cell.imageView?.image = nil
    cell.selectionStyle = .none
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    sideMenuController?.hideMenu(animated: true, completion: { [weak self] flag in
      guard let `self` = self else { return }
      let selStr = self.actions[indexPath.row].sel
      let sel = NSSelectorFromString(selStr)
      if self.responds(to: sel) {
        self.perform(sel)
      }
    })
   
    
  }
  
}

extension BaseViewController {
 
  
  @objc func home() {
    let tab = sideMenuController?.contentViewController as? BaseTabBarController
    tab?.selectedIndex = 0
  }
  
  @objc func myWallet() {
    let vc = MyWalletController(defautIndex: 0)
    pushToVc(vc)
  }
  
  @objc func appointments() {
    let tab = sideMenuController?.contentViewController as? BaseTabBarController
    tab?.selectedIndex = 1
  }
  
  @objc func services() {
    let vc = WebBrowserController(url: WebUrl.services)
    pushToVc(vc)
  }
 
  @objc func shop() {
    let vc = ShopViewController()
    pushToVc(vc)
  }
  
  @objc func myOrders() {
    let vc = MyOrdersController()
    pushToVc(vc)
  }
  
  @objc func symptomChecker() {
    let vc = SymptomCheckBeginController()
    pushToVc(vc)
  }
  
  @objc func conditionsWeTreat() {
    let vc = WebBrowserController(url: WebUrl.conditionsWeTreat)
    pushToVc(vc)
  }
  
  @objc func blog() {
    let vc = BlogViewController()
    pushToVc(vc)
  }
  
  @objc func madamPartum() {
    let vc = MadamPartumController()
    pushToVc(vc)
  }
  
  @objc func bookmarks() {
    let vc = BlogBoardsController()
    pushToVc(vc)
  }
  
  @objc func referToFriend() {
    let vc = ReferFriendController()
    pushToVc(vc)
  }
  
  @objc func ourStory() {
    let vc = WebBrowserController(url: WebUrl.ourStory)
    pushToVc(vc)
  }
  
  @objc func contactUs() {
    let vc = ContactUsViewController()
    pushToVc(vc)
  }
  
  @objc func frequentlyAskedQuestions() {
    let vc = QuestionHelperController()
    pushToVc(vc)
    
  }
  
  func pushToVc(_ vc:UIViewController) {
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
  }
 
  @objc func editProfile() {
    sideMenuController?.hideMenu(animated: true, completion: { [weak self] flag in
      guard let `self` = self else { return }
      let vc = EditProfileViewController()
      self.navigationController?.pushViewController(vc)
    })
    
  }
  
}

class MenuHeadView: UIView {
  var nameLabel = UILabel().then { label in
    label.textColor = .white
    label.font = UIFont(name: .AvenirNextDemiBold, size:24)
  }
  var editButton = UIButton().then { btn in
    btn.imageForNormal = R.image.menu_edit()
  }
  
  var editHandler:(()->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(nameLabel)
    addSubview(editButton)
    editButton.addTarget(self, action: #selector(editAction),for: .touchUpInside)
    NotificationCenter.default.addObserver(self, selector: #selector(setUserName(_:)), name: .menuInfoShouldChange, object: nil)
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    nameLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(64)
    }
    editButton.snp.makeConstraints { make in
      make.centerY.equalTo(nameLabel)
      make.left.equalTo(nameLabel.snp.right).offset(18)
    }
  }
  
  @objc func editAction() {
    NotificationCenter.default.post(name: .menuDidOpenVc, object: "editProfile")
  }
  
  @objc func setUserName(_ noti:Notification) {
    let user = noti.object as! UserModel
    let name = user.first_name + " " + user.last_name
    nameLabel.text = "Hi," + name
  }
}
