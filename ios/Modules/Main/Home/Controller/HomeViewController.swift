//
//  HomeViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/29.
//

import UIKit
import SideMenuSwift
import PromiseKit

enum ScanType {
  case Home
  case CheckIn
}
class HomeViewController: BaseViewController {
  
  var scrolView = UIScrollView()
  var contentView = HomeContainer.loadViewFromNib()
  var scanType: ScanType = .Home
  var checkInSessionModel = BookingTodayModel()
  init() {
    super.init(nibName: nil, bundle: nil)
    NotificationCenter.default.addObserver(forName: .todayCheckIn, object: nil, queue: .main) { noti in
      self.checkInSessionModel = noti.object as! BookingTodayModel
      self.showScanVc()
      self.scanType = .CheckIn
      
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
    
    self.view.addSubview(scrolView)
    scrolView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kTabBarHeight)
    scrolView.contentSize = CGSize(width: kScreenWidth, height: kScreenHeight)
    
    scrolView.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    
    let header = RefreshAnimationHeader{ [weak self] in
      self?.refreshData()
    }
    header.colorStyle = .gray
    scrolView.mj_header = header
    
    contentView.updateContentHeight = { [weak self] height in
      self?.contentView.height = height
      self?.scrolView.contentSize = CGSize(width: kScreenWidth, height: height)
    }
    
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshData()
  }
  
  
  func refreshData() {
   
    firstly {
      self.getTClientPartInfo()
    }.done { _ in
      self.getBookedService()
    }.catch { e in
      self.scrolView.mj_header?.endRefreshing()
      print(e.asAPIError.errorInfo().message)
    }
  }
  
  func getBookedService() {
    when(fulfilled: getTodaySession(),getUpComingSession()).done { (today,upcoming) in
      
      if today.count == 0 && upcoming.count == 0 { // 显示名称
        self.contentView.updateAppointmentViewData(viewType: .Wellcom)
      }else if upcoming.count > 0 && today.count == 0 { // 显示upcoming
        self.contentView.updateAppointmentViewData(viewType: .Upcoming,upcoming: upcoming)
      }else if today.count > 0 { // 有today 则不显示upcoming
        self.contentView.updateAppointmentViewData(viewType: .Today,today: today)
      }
      
      self.getFeaturedAllBlogs()
      self.getNewReCardAmount()
      self.scrolView.mj_header?.endRefreshing()
      
    }.catch { e in
      self.getFeaturedAllBlogs()
      self.getNewReCardAmount()
      self.contentView.updateAppointmentViewData(viewType: .Wellcom)
      self.scrolView.mj_header?.endRefreshing()
      print(e.asAPIError.errorInfo().message)
    }
  }
  
  
  func getFeaturedAllBlogs() {
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
  
  func getTClientPartInfo() -> Promise<Void> {
    Promise.init { resolver in
      
      let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
          self.contentView.userModel = model
          Defaults.shared.set(model, for: .userModel)
          NotificationCenter.default.post(name: .menuInfoShouldChange, object: model)
          resolver.fulfill_()
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "GetTClientPartInfo Failed"))
        
      } errorHandler: { e in
        resolver.fulfill_()
      }
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
  
  func getTodaySession() -> Promise<[BookingTodayModel]>{
    Promise.init { resolver in
      let params = SOAPParams(action: .BookingOrder, path: .getClientBookedServices)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "date", value: Date().string(withFormat: "yyyy-MM-dd"))
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(BookingTodayModel.self, from: data) {
          resolver.fulfill(models)
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "GetTodaySession Failed"))
      } errorHandler: { e in
        resolver.reject(e.asAPIError)
      }
    }
  }
  
  func getUpComingSession() -> Promise<[BookingUpComingModel]>{
    Promise.init { resolver in
      let params = SOAPParams(action: .ClientProfile, path: .getTUpcomingAppointments)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "startDateTime", value: Date().tomorrow.string(withFormat: "yyyy-MM-dd").appending(" 00:00:00"))
      params.set(key: "wellnessType", value: "")
      params.set(key: "start", value: 0)
      params.set(key: "length", value: 30)
      NetworkManager().request(params: params) { data in
       
        if let models = DecodeManager.decodeArrayByHandJSON(BookingUpComingModel.self, from: data){
          resolver.fulfill(models)
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "GetUpComingSession Failed"))
      } errorHandler: { e in
        resolver.reject(e.asAPIError)
      }

    }
  }

  
  @objc func leftItemAction() {
    sideMenuController?.revealMenu()
  }
  
  @objc func rightItemAction() {
    showScanVc()
    scanType = .Home
  }
  
  func showScanVc() {
    var configuration = QRScannerConfiguration()
    configuration.title = ""
    configuration.hint = "Scan the Outlet QR Code"
    configuration.color = .white
    configuration.thickness = 2
    configuration.length = 44
    configuration.radius = 22
    configuration.readQRFromPhotos = false
    configuration.previewSize = CGSize(width: kScreenWidth - 48, height: kScreenWidth - 48)
    configuration.roundCornerSize = CGSize(width: kScreenWidth - 24, height: kScreenWidth - 24)
    
    let scanner = QRCodeScannerController(qrScannerConfiguration: configuration)
    scanner.delegate = self
    self.navigationController?.pushViewController(scanner, completion: nil)
  }
  
}

extension HomeViewController: QRScannerCodeDelegate {
    func qrScannerDidFail(_ controller: UIViewController, error: QRCodeError) {
        print("error:\(error.localizedDescription)")
    }
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        print("result:\(result)")
      let json = JSON(parseJSON: result)
      let locationName = json["name"].stringValue
      let id = json["id"].stringValue
      let type = json["type"].stringValue
      if scanType == .Home {
        let vc = CheckInTodaySessionController(locationName: locationName)
        self.navigationController?.pushViewController(vc, completion: nil)
      }
      if scanType == .CheckIn {
        
        let vc = ConfirmSessionController(todayModel: self.checkInSessionModel)
        self.navigationController?.pushViewController(vc, completion: nil)
        
      }
      
      
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }
}
