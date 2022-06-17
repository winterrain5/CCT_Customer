//
//  BookingUpComingDetailController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/17.
//

import UIKit

class BookingUpComingWellnessController: BaseViewController {
  
  let contentView = BookingUpComingWellnessView.loadViewFromNib()
  var upcoming: BookingUpComingModel?
  var today: BookingTodayModel?
  
  convenience init(upcoming:BookingUpComingModel) {
    self.init()
    self.upcoming = upcoming
    
  }
  
  convenience init(today:BookingTodayModel) {
    self.init()
    self.today = today
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.isSkeletonable = true
    self.view.backgroundColor = R.color.theamBlue()
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    contentView.checkInHandler = { [weak self] model in
      self?.showScanVc()
    }
    getCompanyInfo()
  }
  
  
  func getCompanyInfo() {
    let params = SOAPParams(action: .Company, path: .getTCompany)
    var id:String = ""
    if upcoming != nil {
      id = upcoming?.location_id ?? ""
    }
    if today != nil {
      id = today?.location_id ?? ""
    }
    params.set(key: "id", value: id)
    self.view.showSkeleton()
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(CompanyModel.self, from: data) {
        self.contentView.company = model
        self.contentView.upcoming = self.upcoming
        self.contentView.today = self.today
      }
      self.view.hideSkeleton()
    } errorHandler: { e in
      self.view.hideSkeleton()
    }

  }
  
}
extension BookingUpComingWellnessController: QRScannerCodeDelegate {
  
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
  
  func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
    print("result:\(result)")
//    let json = JSON(parseJSON: result)
//    let locationName = json["name"].stringValue
//    let id = json["id"].stringValue
//    let type = json["type"].stringValue
    
    if let today = today {
      let vc = ConfirmSessionController(todayModel: today)
      self.navigationController?.pushViewController(vc, completion: nil)
    }
  
    
    
  }
  
  func qrScannerDidCancel(_ controller: UIViewController) {
    print("SwiftQRScanner did cancel")
  }
}
