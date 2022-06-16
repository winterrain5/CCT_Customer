//
//  SymptomCheckWhatNextController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/13.
//

import UIKit

class SymptomCheckWhatNextController: BaseViewController {
  
  private var container = SymptomCheckWhatNextContainer.loadViewFromNib()
  private var scrollView = UIScrollView().then { view in
    view.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    view.bounces = false
  }
  private var isSaveReport:Bool = true
  private var result:[Int:[SymptomCheckStepModel]] = [:]
  init(result:[Int:[SymptomCheckStepModel]] = [:]) {
    super.init(nibName: nil, bundle: nil)
    self.result = result
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.bar.alpha = 0
    self.view.backgroundColor = R.color.theamBlue()
    self.interactivePopGestureRecognizerEnable = false
    self.barAppearance(tintColor: .white,barBackgroundColor: .white, image: R.image.return_left(),backButtonTitle: "Exit")
    self.view.addSubview(scrollView)
    self.scrollView.addSubview(container)
    let containerH = 701 + kBottomsafeAreaMargin
    container.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: containerH < kScreenHeight ? kScreenHeight : containerH)
    scrollView.contentSize = CGSize(width: kScreenWidth, height: container.height)
    
    container.bookAppointmentHandler = {
      let params = SOAPParams(action: .Client, path: .getClientCancelCount)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      Toast.showLoading()
      NetworkManager().request(params: params) { data in
        Toast.dismiss()
        let count = JSON.init(from: data)?["cancel_count"].rawString()?.int ?? 0
        if count > 3 {
          AlertView.show(message: "If you delay cancelling more than 3 times, your in app reservation permission will be suspended.")
        }else {
          let vc = BookingAppointmentController(type: .Treatment)
          self.saveReport(vc)
        }
      } errorHandler: { e in
        Toast.dismiss()
      }

    }
    container.saveReportHandler = {
      [weak self] isSave in
      self?.isSaveReport = isSave
    }
    container.emailMeHandler = {
      [weak self] in
      guard let `self` = self else { return }
      self.saveReport(SymptomCheckEmailMeController(result: self.result))
    }
    container.backHandler = {
      [weak self] in
      self?.backAction()
    }
    container.doneHandler = {
      [weak self] in
      self?.saveReport(SymptomCheckBeginController())
    }
    
  }
  func saveReport(_ toVc:BaseViewController?,isPop:Bool = false) {
    if !isPop {
      if !isSaveReport {
        guard let vc = toVc else { return }
        self.navigationController?.pushViewController(vc)
        return
      }
    }
    
    let params = SOAPParams(action: .questionnaireSurvey, path: .savePatientResults)
    let summaryData = SOAPDictionary()
    func getQAID(by key:Int,isArrayString:Bool = true) -> String{
      if isArrayString {
        return JSON.init(result.filter({ $0.key == key }).first?.value.map({ $0.id?.int ?? 0 }) ?? []).rawString()?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\\\"", with: "") ?? ""
      }else {
        return result.filter({ $0.key == key }).first?.value.map({ $0.id ?? "" }).first ?? ""
      }
      
    }
    
    summaryData.set(key: "symptoms_qa_id", value: getQAID(by: 1))
    summaryData.set(key: "best_describes_qa_id", value: getQAID(by: 2,isArrayString: false))
    summaryData.set(key: "pain_areas_qa_ids", value: getQAID(by: 3))
    summaryData.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
    summaryData.set(key: "registration_id", value: 0)
    summaryData.set(key: "sign_img", value: "")
    summaryData.set(key: "create_time", value: Date().string(withFormat: "yyyy-MM-dd HH:mm:ss"))
    summaryData.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
    summaryData.set(key: "remarks", value: "")
    summaryData.set(key: "category", value: 6)
    summaryData.set(key: "location_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    
    let data = SOAPDictionary()
    data.set(key: "Summary_Data", value: summaryData.result, keyType: .string, valueType: .map(1))
    params.set(key: "data", value: data.result, type: .map(1))
    
    let logData = SOAPDictionary()
    logData.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
    logData.set(key: "ip", value: "")
    
    params.set(key: "logData", value: logData.result,type: .map(2))
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      if isPop {
        self.navigationController?.popToRootViewController(animated: true)
      }else {
        guard let vc = toVc else { return }
        self.navigationController?.pushViewController(vc)
      }
      
    } errorHandler: { e in
      Toast.dismiss()
    }
    
    
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.updateStatusBarStyle(true)
  }
  
  override func backAction() {
    AlertView.show(title: "Are you sure you want to Exit?", rightHandler:  {
      self.saveReport(nil, isPop: true)
    })
  }
  
}
