//
//  BookingUpcomingTreatmentController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/17.
//

import UIKit
import PromiseKit
import RxSwift
class BookingUpcomingTreatmentController: BaseViewController {

  let treatmentView = BookingUpcomingTreatmentView.loadViewFromNib()
  let scrollView = UIScrollView()
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
    
    self.view.addSubview(scrollView)
    scrollView.isScrollEnabled = true
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    scrollView.contentSize = CGSize(width: kScreenWidth, height: kScreenHeight)
    scrollView.bounces = false
    
    scrollView.addSubview(treatmentView)
    treatmentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    treatmentView.checkInHandler = { [weak self] model in
      self?.showScanVc()
    }
    treatmentView.updateHeightHandler = { [weak self] height in
      self?.scrollView.contentSize = CGSize(width: kScreenWidth, height: height)
      self?.treatmentView.height = height
    }
    
    self.view.showSkeleton()
    when(fulfilled: getCompanyInfo(), getLastSymptomCheckReport()).done { _,_ in
      self.view.hideSkeleton()
    }.catch { e in
      self.view.hideSkeleton()
    }
  }
  
  
  func getCompanyInfo() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Company, path: .getTCompany)
      var id:String = ""
      if upcoming != nil {
        id = upcoming?.location_id ?? ""
      }
      if today != nil {
        id = today?.location_id ?? ""
      }
      params.set(key: "id", value: id)
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(CompanyModel.self, from: data) {
          self.treatmentView.company = model
          self.treatmentView.upcoming = self.upcoming
          self.treatmentView.today = self.today
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode CompanyModel Failed"))
        }
        
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
    

  }
  
  
  func getLastSymptomCheckReport() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .SymptomCheck, path: .getLastSymptomCheckReport)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "date", value: Date().string(withFormat: "yyyy-MM-dd"))
      
      NetworkManager().request(params: params) { data in
       
        if let model = DecodeManager.decodeObjectByHandJSON(SymptomCheckReportModel.self, from: data) {
          
          var result:[[SymptomCheckStepModel]] = []
          
          let symptoms = model.symptoms_qas?.map({ e -> SymptomCheckStepModel in
            let m = SymptomCheckStepModel()
            m.title = e.title
            return m
          })
          
          let lastActivity = SymptomCheckStepModel()
          lastActivity.title = model.best_describes_qa_title ?? ""
          
          let area = model.pain_areas?.map({ e -> SymptomCheckStepModel  in
            let m = SymptomCheckStepModel()
            m.title = e.title
            return m
          })
          
          result.append(symptoms ?? [])
          result.append([lastActivity])
          result.append(area ?? [])
          
          self.treatmentView.result = result
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode CompanyModel Failed"))
        }
        
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
    
  }

}
extension BookingUpcomingTreatmentController: QRScannerCodeDelegate {
  
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
