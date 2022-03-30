//
//  MainViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/30.
//

import UIKit
import Stripe
import DKLogger
import IQKeyboardManagerSwift
class MainViewController: BaseViewController {
  lazy var createBoardView = BlogCreateBoardSheetView()
  var blogId:String = ""
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(openNativeVc(_:)), name: NSNotification.Name.openNativeVc, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(goBack(_:)), name: NSNotification.Name.goBackNativeVc, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(goBackToRootNativeVc), name: NSNotification.Name.goBackToRootNativeVc, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(openWebVc(_:)), name: NSNotification.Name.openWebVc, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(payment(_:)), name: NSNotification.Name.payment, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(saveClientId(_:)), name: NSNotification.Name.saveClientId, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(saveUserId(_:)), name: NSNotification.Name.saveUserId, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(saveLoginPwd(_:)), name: NSNotification.Name.saveLoginPwd, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(saveCompanyId(_:)), name: NSNotification.Name.saveCompanyId, object: nil)
  
   
    NotificationCenter.default.addObserver(self, selector: #selector(setBlogStatus(_:)), name: NSNotification.Name.setBlogStatus, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(shareBlog(_:)), name: NSNotification.Name.shareBlog, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(removeLocalData), name: NSNotification.Name.removeLocalData, object: nil)
    configKeyBoard()
    
    setPushAlias(id: Defaults.shared.get(for: .userId) ?? "")
    
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  func setPushAlias(id: String) {
    if id.isEmpty { return }
    MobPush.setAlias("client_\(id)") { e in
      if let e = e {
        print("setAlias error:\(e.localizedDescription)")
      }else {
        print("setAlias success id:client_\(id)")
      }
    }
  }
  
  @objc func saveClientId(_ noti:NSNotification) {
    let obj = noti.object as? String ?? ""
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: obj)
    Defaults.shared.set(obj, for: .clientId)
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decode(UserModel.self, from: data) {
        Defaults.shared.set(model, for: .userModel)
        self.setPushAlias(id: model.id ?? "")
      }
    } errorHandler: { e in
      
    }
  }
  @objc func saveUserId(_ noti:NSNotification) {
    let obj = noti.object as? String ?? ""
    Defaults.shared.set(obj, for: .userId)
  }
  @objc func saveCompanyId(_ noti:NSNotification) {
    let obj = noti.object as? String ?? ""
    Defaults.shared.set(obj, for: .companyId)
    
  }
  @objc func saveLoginPwd(_ noti:NSNotification) {
    let obj = noti.object as? String ?? ""
    Defaults.shared.set(obj, for: .loginPwd)
  }
  
  
  func configKeyBoard() {
    let manager = IQKeyboardManager.shared
    manager.enable = true
    manager.shouldResignOnTouchOutside = true
    manager.shouldShowToolbarPlaceholder = false
    manager.enableAutoToolbar = false
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigation.bar.isHidden = true
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 20
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigation.bar.isHidden = false
  }
  
  @objc func openNativeVc(_ noti:Notification) {
   
    let vcName = noti.object as? String ?? ""
    let params = noti.userInfo
    guard let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
      print("没有获取到命名空间")
      return
      
    }
    
    guard let vcType:AnyObject.Type = NSClassFromString("\(nameSpace).\(vcName)") else {
      print("没有获取到对应的类")
      return
    }
    
    guard let vc = vcType as? BaseViewController.Type else{
      print("没有转换成vc")
      return
    }
    
    let temp = vc.init()
    if temp is BlogDetailViewController {
      let vc = (temp as! BlogDetailViewController)
      vc.blogId = params?["blogId"] as? String ?? ""
      vc.hasBook = params?["hasBook"] as? Bool ?? false
      self.navigationController?.pushViewController(vc)
      return
    }
    
    if temp is RNBridgeViewController {
      let vc = (temp as! RNBridgeViewController)
      vc.RNProperty = params?["property"] as? Dictionary ?? [:]
      vc.RNPageName = params?["pageName"] as? String ?? ""
      self.navigationController?.pushViewController(vc)
      return
    }
    
    self.navigationController?.pushViewController(temp)
    
    
  }
  
  @objc func goBack(_ noti:Notification) {
    self.navigationController?.popViewController()
  }
  @objc func goBackToRootNativeVc() {
    UIViewController.getTopVC()?.navigationController?.popToRootViewController(animated: true)
  }
  
  @objc func openWebVc(_ noti:Notification) {
    let url = noti.object as? String ?? ""
    let vc = WebBrowserController(url: url)
    vc.navTitle = ""
    self.navigationController?.pushViewController(vc)
  }
  
  @objc func payment(_ noti:Notification) {
    guard let info = noti.object as? String else { return }
    let json = JSON.init(parseJSON: info)
    let clientSecret = json["clientSecret"].rawString() ?? ""
    let card = STPPaymentMethodCardParams()
    card.cvc = json["cvc"].rawString() ?? ""
    card.expYear = NSNumber.init(value: (json["expYear"].string ?? "0").int ?? 0)
    card.expMonth = NSNumber.init(value: (json["expMonth"].string ?? "0").int ?? 0)
    card.number = json["number"].rawString() ?? ""
    let params = STPPaymentMethodParams(card: card, billingDetails: nil, metadata: nil)
    
    let intent = STPPaymentIntentParams(clientSecret: clientSecret)
    intent.paymentMethodParams = params
    Toast.showLoading()
    STPAPIClient().confirmPaymentIntent(with: intent) { result, e in
      Toast.dismiss()
      if e != nil {
        
        Toast.showError(withStatus: e?.localizedDescription ?? "")
        return
      }
      NotificationCenter.default.post(name: .nativeNotification, object: "\(result?.status.rawValue ?? 0)",userInfo: ["type":"PaymentStatus"])
    }
  }
  
  @objc func shareBlog(_ noti:Notification) {
    let blogId = noti.userInfo?["blogId"] as? String ?? ""
    let title = noti.userInfo?["title"] as? String ?? ""
    guard let url = URL(string: "\(APIHost().URL_BLOG_SHARE)\(blogId)") else {
      return
    }
    ShareTool.shareBlog(title, url.absoluteString)
  }
  
  @objc func setBlogStatus(_ noti:Notification) {
    self.blogId = noti.userInfo?["blogId"] as? String ?? ""
    let bookMarked = noti.userInfo?["bookMarked"] as? String ?? ""
    if bookMarked == "1" {
      self.deleteBlogFromBoard()
    }else {
      self.checkHasDefaultBoards()
    }
  }
  
  func checkHasDefaultBoards() {
    Toast.showLoading()
    let params = SOAPParams(action: .Blog, path: API.checkHasDefaultBoards)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      self.getBoardsForAddBlog()
    } errorHandler: { e in
      self.getBoardsForAddBlog()
    }

  }
  
  func getBoardsForAddBlog() {
    
    let params = SOAPParams(action: .Blog, path: API.getBoardsForAddBlog)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      guard let boards = DecodeManager.decode([BlogBoardModel].self, from: data) else {
        return
      }
      let saveBoardView = BlogSaveToBoardSheetView.loadViewFromNib()
      saveBoardView.boards = boards
      let size = CGSize(width: kScreenWidth, height: saveBoardView.viewHeight)
      EntryKit.display(view: saveBoardView,
                       size: size,
                       style: .sheet,
                       backgroundColor: UIColor.black.withAlphaComponent(0.8),
                       touchDismiss: true)
      
      saveBoardView.createBoardHandler = {
        EntryKit.dismiss {
          self.createBoardView.showView(from: self.view)
          self.createBoardView.contentView.addBoardHandler = {  text in
            self.saveBoard(text)
          }
        }
      }
      
      saveBoardView.selectBoardHandler = { model in
        self.saveBlogToBoard(boardId: model.id!)
      }
      
    } errorHandler: { error in
      
    }

  }
  
  func saveBoard(_ name:String) {
    let params = SOAPParams(action: .Blog, path: API.saveBoard)
    let data = SOAPDictionary()
    data.set(key: "id", value: 0)
    data.set(key: "name", value: name)
    data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
      
      self.createBoardView.dismiss()
      self.getBoardsForAddBlog()
      
    } errorHandler: { error in
      
    }
  }
  
  func saveBlogToBoard(boardId:String) {
    let params = SOAPParams(action: .Blog, path: API.saveBlogIntoBoard)
    let data = SOAPDictionary()
    data.set(key: "blog_id", value: self.blogId)
    data.set(key: "board_id", value: boardId)
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
      NotificationCenter.default.post(name: .nativeNotification, object: "1",userInfo: ["type":"BlogBookMarkStatus"])
      EntryKit.dismiss {
        Toast.showSuccess(withStatus: "Add Successful")
      }
      
    } errorHandler: { error in
      
    }
  }
  
  func deleteBlogFromBoard() {
    BlogBookmarkRemoveSheetView.show {
      Toast.showLoading()
      let params = SOAPParams(action: .Blog, path: API.deleteBlogFromBoard)
      params.set(key: "blogId", value: self.blogId)
      NetworkManager().request(params: params) { data in
        Toast.dismiss()
        NotificationCenter.default.post(name: .nativeNotification, object: "0",userInfo: ["type":"BlogBookMarkStatus"])
      } errorHandler: { e in
        
      }
    }
  }
  
  @objc func removeLocalData() {
    Defaults.shared.removeAll()
  }
}
