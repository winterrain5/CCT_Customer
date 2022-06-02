//
//  HomeViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/29.
//

import UIKit
import SideMenuSwift
class HomeViewController: BaseViewController {
  
  var scrolView = UIScrollView()
  var contentView = HomeContainer.loadViewFromNib()
  init() {
    super.init(nibName: nil, bundle: nil)
    NotificationCenter.default.addObserver(forName: .bookingDataChanged, object: nil, queue: .main) { noti in
      
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: nil, backButtonTitle: nil)
    self.navigation.item.leftBarButtonItem = UIBarButtonItem(image: R.image.notification_menu(), style: .plain, target: self, action: #selector(leftItemAction))
    self.navigation.item.rightBarButtonItem = UIBarButtonItem(image: R.image.home_nav_scan(), style: .plain, target: self, action: #selector(rightItemAction))
    self.navigation.item.title = "Chien Chi Tow"
    getClientByUserId()
    
    self.view.addSubview(scrolView)
    scrolView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kTabBarHeight)
    scrolView.contentSize = CGSize(width: kScreenWidth, height: kScreenHeight)
    
    scrolView.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshData()
  }
  
  
  func refreshData() {
    getFeaturedAllBlogs()
    getNewReCardAmount()
    if Defaults.shared.get(for: .clientId) == nil {
      getClientByUserId()
    }else {
      getTClientPartInfo()
    }
  }
  
  
  func getFeaturedAllBlogs()  {
    let params = SOAPParams(action: .Blog, path: API.getAllBlogs)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "isFeatured", value: 1)
    params.set(key: "categoryId", value: 0)
    params.set(key: "limit", value: 4)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      
      guard let models = DecodeManager.decodeArrayByHandJSON(BlogModel.self, from: data) else {
        return
      }
      self.contentView.blogDatas = models
    } errorHandler: { error in
    }
  }
  
  func getClientByUserId() {
    
    let params = SOAPParams(action: .Client, path: .getTClientByUserId)
    params.set(key: "userId", value: Defaults.shared.get(for: .userId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let id = try? JSON(data: data)["id"].rawString() {
        Defaults.shared.set(id, for: .clientId)
        self.getTClientPartInfo()
      }
    } errorHandler: { e in
      
    }
  }
  
  func getTClientPartInfo() {
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        self.contentView.userModel = model
        Defaults.shared.set(model, for: .userModel)
        NotificationCenter.default.post(name: .menuInfoShouldChange, object: model)
      }
    } errorHandler: { e in
      
    }
  }
  
  func getNewReCardAmount() {
    
    let params = SOAPParams(action: .Voucher, path: .getNewReCardAmountByClientId)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      self.contentView.money = String(data: data, encoding: .utf8)?.formatMoney().dolar ?? ""
    } errorHandler: { e in
      
    }
  }

  
  @objc func leftItemAction() {
    sideMenuController?.revealMenu()
  }
  
  @objc func rightItemAction() {
    
    
  }
  
}
