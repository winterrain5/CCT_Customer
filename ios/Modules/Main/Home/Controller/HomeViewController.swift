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
      
      let tab = self.sideMenuController?.contentViewController as? BaseTabBarController
      if tab?.selectedIndex == 0 {
        self.checkInSessionModel = noti.object as! BookingTodayModel
        self.showScanVc()
        self.scanType = .CheckIn
      }
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
    
    getAppVersion()
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
    params.set(key: "filterKeys", value: 0)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    let search = SOAPDictionary()
    params.set(key: "searchData", value: search.result, type: .map(1))
    
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
  
  func getAppVersion() {
    let params = SOAPParams(action: .AppConfig, path: .getAll)
    params.set(key: "typeId", value: 2)
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(AppVersionModel.self, from: data) {
        
        //把版本号转换成数值 默认版本号1.0.0类型
        let array1 = Device.appVersion.split(separator: ".").map({ String($0).int })
        var currentVersion:Int = 0
        if (array1.count == 3){
          currentVersion = array1[0]!*100 + array1[1]!*10 + array1[2]!
        }else if(array1.count == 2){
          currentVersion = array1[0]!*100 + array1[1]!*10
        }
        
        let array2 = model.version.split(separator: ".").map({ String($0).int }) // 1.0.1 => [1,0,1]
        var newVersion:Int = 0
        if (array2.count == 3) { // 1.0.1
          newVersion = array2[0]!*100 + array2[1]!*10 + array2[2]!
        }else if(array2.count == 2){ // 1.0
          newVersion = array2[0]!*100 + array2[1]!*10
        }
        
        if currentVersion == 100 { // first version
          Defaults.shared.set(true, for: .isReview)
          self.contentView.updateKingKongData(true)
          return
        }
        
        if newVersion < currentVersion { // 后台版本小于当前版本 则为在审核中
          Defaults.shared.set(true, for: .isReview)
          self.contentView.updateKingKongData(true)
        }else if newVersion == currentVersion{ // 相等则为最新版本
          Defaults.shared.set(false, for: .isReview)
          self.contentView.updateKingKongData(false)
        }else { // 后台版本大于当前版本 提示更新
          Defaults.shared.set(false, for: .isReview)
          self.contentView.updateKingKongData(false)
        }
        
        if model.is_force == 1 && newVersion > currentVersion{ // 弹窗提示更新
          let alertVc = UIAlertController(title: "New Version", message: model.update_content, preferredStyle: .alert)
          let action1 = UIAlertAction(title: "Confirm", style: .default) { _ in
            let url = URL(string: URL_App_Store)
            if let url = url, UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url)
            }
          }
          
          alertVc.addAction(action1)
          self.present(alertVc, animated: true)
        }
        
      }
    } errorHandler: { e in
      Defaults.shared.set(true, for: .isReview)
      self.contentView.updateKingKongData(true)
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
      params.set(key: "start", value: 1)
      params.set(key: "length", value: 5)
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
  
  
}

extension HomeViewController: QRScannerCodeDelegate {
  
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
  
  
  func qrScannerDidFail(_ controller: UIViewController, error: QRCodeError) {
    print("error:\(error.localizedDescription)")
  }
  
  /**
   # 二维码类型
   BOOKING_DETAIL = 1 # 订单详情二维码，供CustomerApp扫码填写问卷（用于BookingViewSet.getBookingDetailQrCodeBytesStrById()接口）
   PAY_ORDER = 2 # 订单支付二维码，供CustomerApp扫码进行支付（用于SaleOrderViewSet.generateOrder()接口）
   **/
  func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
    print("result:\(result)")
    let json = JSON(parseJSON: result)
    
    if json["type"].stringValue == "1" { // 问卷二维码
      let content = json["content"]
      if content["client_id"].stringValue != Defaults.shared.get(for: .clientId) {
        AlertView.show(message: "Sorry, this is not your questionnaire QR code, please contact the staff", messageAlignment: .left) {
          controller.navigationController?.popViewController()
        }
        
        return
      }
      
      let params = ConfirmSessionModel()
      
      let date = content["therapy_start_date"].stringValue.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      params.time = date?.timeString(ofStyle: .short) ?? ""
      params.date = date?.string(withFormat: "dd MMM yyyy,EEE") ?? ""
      params.location = content["location"].stringValue
      params.outlet_id = content["location_id"].stringValue
      params.remark = content["remark"].stringValue
      params.business_name = content["employee_name"].stringValue
      params.service_type = .Therapist
      params.service_name = content["alias_name"].stringValue
      params.service_id = content["service_durations_id"].stringValue
      params.duration = content["time_minutes"].stringValue
      params.booking_id = content["booking_order_times_id"].stringValue
      params.health_declaration_form_type = content["health_declaration_form_type"].intValue
      params.isSyncCalendar = true
      params.isScanQRCode = true
      
      let vc = ConfirmSessionController(params: params)
      self.navigationController?.pushViewController(vc)
      
      return
    }
    
    if json["type"].stringValue == "2" { // 订单支付二维码
      let content = json["content"]
      let orderId = content["sale_order_id"].stringValue
      let sessionId = content["session_id"].stringValue
      let vc = HomeServiceViewController(orderId: orderId, sessionId: sessionId)
      self.navigationController?.pushViewController(vc)
      return
    }
    
    let locationName = json["name"].stringValue
    let id = json["id"].stringValue
    if scanType == .Home {
      let vc = CheckInTodaySessionController(outlet: (id:id,name:locationName))
      self.navigationController?.pushViewController(vc, completion: nil)
    }
    if scanType == .CheckIn {
      if self.checkInSessionModel.location_id != id {
        AlertView.show(message: "The branch you scanned does not match the branch you served!")
        controller.navigationController?.popViewController()
        return
      }
      let vc = ConfirmSessionController(todayModel: self.checkInSessionModel)
      self.navigationController?.pushViewController(vc, completion: nil)
    }
    
    
  }
  
  func qrScannerDidCancel(_ controller: UIViewController) {
    print("SwiftQRScanner did cancel")
  }
}
