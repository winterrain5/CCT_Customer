//
//  WellnessAppointmentController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/20.
//

import UIKit

import HandyJSON

class ServiceFormModel {
  
  enum FormDataType {
    case outlet
    case service
    case therapist
    case date
    case timeSlot
    case note
  }
  var placeHolder:String = ""
  var title:String = ""
  var rightImage:UIImage?
  var type:FormDataType = .outlet
  var sel:String = ""
  
  init(placeHolder:String,rightImage:UIImage?,sel:String,title:String = "",type:FormDataType) {
    self.placeHolder = placeHolder
    self.title = title
    self.rightImage = rightImage
    self.type = type
    self.sel = sel
    
  }
}

enum ServiceType:Int {
  /// 0 看诊
  case Treatment = 0
  /// 1 服务（日期）
  case DateTime
  /// 2 服务 （人员）
  case Therapist
}

class BookingAppointmentController: BaseTableController {
 
  
  var headLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 24~)
    label.adjustsFontSizeToFitWidth = true
  }
  var headView = UIView().then { view in
    view.backgroundColor = .white
  }
  var footView = BookingServiceFormFooterView.loadViewFromNib()
  var type:ServiceType = .DateTime
  
  var models:[ServiceFormModel] = []
  
  var companyModels:[CompanyModel] = []
  var selectCompany:CompanyModel?
  
  var serviceModels:[BookingServiceModel] = []
  var selectedService:BookingServiceModel?
  
  var dutyDateModels:[BookingDutyDateModel] = []
  var selectedDate:String?
  
  var employeeModels:[EmployeeForServiceModel] = []
  var selectedEmployee:EmployeeForServiceModel?
  
  var bookigTimeModels:[String] = []
  var selectedTime:String?
  
  var isSyncCalendar:Bool = true
  
  var result:[Int:[SymptomCheckStepModel]] = [:]
  var showReport = true
  
  let serviceModel = ServiceFormModel(placeHolder: "Select Service", rightImage: R.image.booking_form_dropdown(), sel: "selectService",type: .service)
  
  convenience init(type: ServiceType, result:[Int:[SymptomCheckStepModel]] = [:],showReport:Bool = true) {
    self.init()
    self.type = type
    self.result = result
    self.showReport = showReport
    
  }
  
  convenience init(type: ServiceType) {
    self.init()
    self.type = type
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = R.color.theamBlue()
    headView.addSubview(headLabel)
    var headTitle = ""
    switch type {
    case .Treatment:
      headTitle = "Book Treatment Appointment"
    case .DateTime:
      headTitle = "Select By Preferred Slot"
    case .Therapist:
      headTitle = "Select By Preferred Therapist"
    }
    headLabel.text = headTitle
    headLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalToSuperview().offset(32)
    }
    
    switch type {
    case .Treatment:
      models = [
        ServiceFormModel(placeHolder: "Select Outlet", rightImage: R.image.booking_form_dropdown(), sel: "selectOutlet",type: .outlet),
        ServiceFormModel(placeHolder: "Select Date", rightImage: R.image.booking_form_calendar(), sel: "selectDate",type: .date),
        ServiceFormModel(placeHolder: "Select Time Slot", rightImage: R.image.booking_form_dropdown(), sel: "selectTimeSlot",type: .timeSlot),
        ServiceFormModel(placeHolder: "Additional Note", rightImage: nil, sel: "additionalNote",type: .note),
      ]
    case .DateTime:
      models = [
        ServiceFormModel(placeHolder: "Select Outlet", rightImage: R.image.booking_form_dropdown(), sel: "selectOutlet",type: .outlet),
        ServiceFormModel(placeHolder: "Select Service", rightImage: R.image.booking_form_dropdown(), sel: "selectService",type: .service),
        ServiceFormModel(placeHolder: "Select Date", rightImage: R.image.booking_form_calendar(), sel: "selectDate",type: .date),
        ServiceFormModel(placeHolder: "Select Time Slot", rightImage: R.image.booking_form_dropdown(), sel: "selectTimeSlot",type: .timeSlot),
        ServiceFormModel(placeHolder: "Additional Note", rightImage: nil, sel: "additionalNote",type: .note),
      ]
    case .Therapist:
      models = [
        ServiceFormModel(placeHolder: "Select Outlet", rightImage: R.image.booking_form_dropdown(), sel: "selectOutlet",type: .outlet),
        ServiceFormModel(placeHolder: "Select Service", rightImage: R.image.booking_form_dropdown(), sel: "selectService",type: .service),
        ServiceFormModel(placeHolder: "Select Therapist", rightImage: R.image.booking_form_dropdown(), sel: "selectTherapist",type: .therapist),
        ServiceFormModel(placeHolder: "Select Date", rightImage: R.image.booking_form_calendar(), sel: "selectDate",type: .date),
        ServiceFormModel(placeHolder: "Select Time Slot", rightImage: R.image.booking_form_dropdown(), sel: "selectTimeSlot",type: .timeSlot),
        ServiceFormModel(placeHolder: "Additional Note", rightImage: nil, sel: "additionalNote",type: .note),
      ]
    }
    
    leftButtonDidClick = { [weak self] in
      self?.navigationController?.popToRootViewController(animated: true)
    }
    
    if showReport {
      getLastSymptomCheckReport()
    }
    
  }
  
  
  
  override func createListView() {
    super.createListView()
    
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    tableView?.separatorStyle = .singleLine
    
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: 84)
    
    tableView?.tableFooterView = footView
    footView.size = CGSize(width: kScreenWidth, height: 226)
    footView.syncCalendar = { [weak self]  isSelect in
      self?.isSyncCalendar = isSelect
    }
    footView.confirmHandler = { [weak self] sender in
      guard let `self` = self else { return }
      guard let startTime = (self.selectedDate?.appending(" ").appending(self.selectedTime ?? "").appending(":00") ?? "").dateTime else { return }
      if Date().compare(startTime) == .orderedDescending {
        Toast.showMessage("The time you selected has expired")
        return
      }
      switch self.type {
      case .Treatment:
        self.checkHasConsultation(sender: sender)
      case .DateTime:
        self.checkRandomBookService(sender: sender)
      case .Therapist:
        self.checkCanBookService(sender: sender)
      }
    }
    var result:[[SymptomCheckStepModel]] = []
    self.result.sorted(by: { $0.key < $01.key}).forEach { key,value in
      result.append(value)
    }
    footView.result = result
    
    tableView?.register(cellWithClass: BookingServiceFormCell.self)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    models.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    63
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BookingServiceFormCell.self)
    cell.model = models[indexPath.row]
    cell.selectionStyle = .none
    cell.textInputEditEndHandler = { [weak self] text in
      self?.models.last?.title = text
      self?.tableView?.reloadData()
      
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model = models[indexPath.row]
    if model.type == .note { return }
    let sel = NSSelectorFromString(model.sel)
    if self.responds(to: sel) {
      self.perform(sel)
    }
  }
  
  
}

extension BookingAppointmentController {
  @objc func selectOutlet() {
    
    if companyModels.count > 0 {
      showCompanySheetView()
    }else {
      getCanOnlineBookingLocation()
    }
    
  }
  @objc func selectService() {
    if selectCompany == nil {
      Toast.showMessage("Please Select a outlet")
      return
    }
    getServiceByLocation()
    
  }
  @objc func selectTherapist() {
    if selectCompany == nil {
      Toast.showMessage("Please Select a outlet")
      return
    }
    if selectedService == nil {
      Toast.showMessage("Please Select a Service")
      return
    }
    getEmployeeForService()
  }
  @objc func selectDate() {
  
    if selectCompany == nil {
      Toast.showMessage("Please Select a outlet")
      return
    }
    if type != .Treatment {
      if selectedService == nil {
        Toast.showMessage("Please Select a Service")
        return
      }
    }
    
    if type == .Therapist {
      if selectedEmployee == nil {
        Toast.showMessage("Please Select a Therapist")
        return
      }
    }
    // 0 : 看诊  1 : 服务(日期) 2 ：服务（人员）
    switch type {
    case .Treatment:
      getDocSchedulesForService()
    case .DateTime:
      getRandomDutyDates()
    case .Therapist:
      getEmployeeDutyDates()
    }
    
 
    
  }
  @objc func selectTimeSlot() {
    if selectCompany == nil {
      Toast.showMessage("Please Select a outlet")
      return
    }
    if type != .Treatment {
      if selectedService == nil {
        Toast.showMessage("Please Select a Service")
        return
      }
    }
    if type == .Therapist {
      if selectedEmployee == nil {
        Toast.showMessage("Please Select a Therapist")
        return
      }
    }
    if selectedDate == nil {
      Toast.showMessage("Please Select a Date")
      return
    }
    
    if type == .DateTime {
      getRandomTimeSlots()
    } else {
      getBokingTimeSlots()
    }
    
    
  }
  
  
  
  func getCanOnlineBookingLocation() {
    
    Toast.showLoading()
    
    let params = SOAPParams(action: .Company, path: .getCanOnlineBookingLocations)
    params.set(key: "pId", value: Defaults.shared.get(for: .companyId) ?? "97")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(CompanyModel.self, from: data) {
        self.companyModels = models
        self.showCompanySheetView()
      }
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
    }
    
  }
  
  func showCompanySheetView() {
    let strs = self.companyModels.map({ $0.alias_name.isEmpty ? $0.name : $0.alias_name })
    BookingServiceFormSheetView.show(dataArray: strs, type: .Outlet) { index in
      
      self.models.forEach({ $0.title = "" })
      self.footView.setConfirmButtonIsReady(false)
      
      self.selectCompany = self.companyModels[index]
      self.models.filter({ $0.type == .outlet }).first?.title = self.companyModels[index].alias_name
      self.tableView?.reloadData()
      
      // 看诊获取默认的服务
      if self.type == .Treatment {
        self.getServiceByLocation()
      }
     
      
    }
  }
  
  func getServiceByLocation() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getServicesByLocation)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "isWellness", value: self.type == .Treatment ? "2" : "1")
    params.set(key: "gendar", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingServiceModel.self, from: data) {
        if self.type == .Treatment {
          if models.count == 1 {
            self.selectedService = models.first
          }
        }else {
          if models.count == 0 {
            Toast.showMessage("No siutable service")
            return
          }
          self.serviceModels = models
          self.showServiceSheetView()
        }
        
      }
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
    }
    
  }
  
  func showServiceSheetView() {
 
    let strs = self.serviceModels.map({ $0.alias_name })
    BookingServiceFormSheetView.show(dataArray: strs, type: .Service) { index in
      
      self.models.filter({ $0.type == .date }).first?.title = ""
      self.models.filter({ $0.type == .timeSlot }).first?.title = ""
      self.models.filter({ $0.type == .therapist }).first?.title = ""
      self.footView.setConfirmButtonIsReady(false)
      
      self.selectedService = self.serviceModels[index]
      self.models.filter({ $0.type == .service }).first?.title = self.selectedService?.alias_name ?? ""
      self.tableView?.reloadData()
    }
  }
  
  func getEmployeeForService() {
    let params = SOAPParams(action: .Schedule, path: .getAppEmployeeForService)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    params.set(key: "gender", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      if let models = DecodeManager.decodeArrayByHandJSON(EmployeeForServiceModel.self, from: data) {
        
        if self.type == .Treatment {
          if models.count == 1 {
            self.selectedEmployee = models.first
          }else {
            self.models.insert(self.serviceModel, at: 1)
            self.tableView?.reloadData()
          }
        } else {
          self.employeeModels = models
          self.showEmployeeSheetView()
        }
        
      }
    } errorHandler: { e in
      Toast.dismiss()
    }

    
  }
  
  func showEmployeeSheetView() {
    
    if self.employeeModels.count == 0 {
      Toast.showMessage("There is no suitable therapist at present")
      return
    }
    
    let strs = self.employeeModels.map({ $0.employee_name })
    BookingServiceFormSheetView.show(dataArray: strs, type: .Therapist) { index in
      
      self.models.filter({ $0.type == .date }).first?.title = ""
      self.models.filter({ $0.type == .timeSlot }).first?.title = ""
      
      self.footView.setConfirmButtonIsReady(false)
      
      self.selectedEmployee = self.employeeModels[index]
      self.models.filter({ $0.type == .therapist }).first?.title = self.selectedEmployee?.employee_name ?? ""
      self.tableView?.reloadData()
    }
  }
  
  func getDocSchedulesForService() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getDocSchedulesForService)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingDutyDateModel.self, from: data) {
        self.dutyDateModels = models
        self.showDateSheetView()
      }
    } errorHandler: { e in
      Toast.showMessage("There is no right date")
    }
    
  }
  
  func getRandomDutyDates() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getRandomDutyDates)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    params.set(key: "gender", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingDutyDateModel.self, from: data) {
        self.dutyDateModels = models
        self.showDateSheetView()
      }
    } errorHandler: { e in
      Toast.showMessage("There is no right date")
    }
  }
  
  func getEmployeeDutyDates() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getEmployeeDutyDates)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "employeeId", value: selectedEmployee?.employee_id ?? "0")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingDutyDateModel.self, from: data) {
        self.dutyDateModels = models
        self.showDateSheetView()
      }
    } errorHandler: { e in
      Toast.showMessage("There is no right date")
    }
  }
  
  func showDateSheetView() {
    if self.dutyDateModels.count == 0 {
      Toast.showMessage("There is no right date")
      return
    }
    Toast.dismiss()
    let strs = self.dutyDateModels.map({ $0.w_date })
    BookingDateSheetView.show(dataArray: strs) { date in
      
      self.models.filter({ $0.type == .timeSlot }).first?.title = ""
      self.footView.setConfirmButtonIsReady(false)
      
      self.selectedDate = date.string(withFormat: "yyyy-MM-dd")
      self.models.filter({ $0.type == .date }).first?.title = date.string(withFormat: "dd MMM yyyy,EEE")
      
      // 看诊选择日期后 自带医生ID
      if self.type == .Treatment {
        let employee = EmployeeForServiceModel()
        employee.employee_id = self.dutyDateModels.filter({ $0.w_date == self.selectedDate }).first?.employee_id ?? ""
        self.selectedEmployee = employee
      }
      
      self.tableView?.reloadData()
    }
  }
  
  func getBokingTimeSlots() {
    Toast.showLoading()
    
    var url:API!
    if type == .Treatment {
      url = .getDocTimeSlots
    }else {
      url = .getBookingTimeSlots
    }
    
    let params = SOAPParams(action: .Schedule, path: url)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "date", value: self.selectedDate ?? "")
    params.set(key: "employeeId", value: selectedEmployee?.employee_id ?? "")
    if self.type != .Treatment {
      params.set(key: "isWellness", value: "1")
    }
    
    
    NetworkManager().request(params: params) { data in
      let times = try? JSON.init(data: data).arrayObject as? [String]
      self.bookigTimeModels = times ?? []
      self.showTimeSheetView()
    } errorHandler: { e in
      Toast.showMessage("There is no right time")
    }
  }
  
  func getRandomTimeSlots() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getRandomTimeSlots)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "date", value: self.selectedDate ?? "")
    params.set(key: "gender", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
    
    NetworkManager().request(params: params) { data in
      let times = try? JSON.init(data: data).arrayObject as? [String]
      self.bookigTimeModels = times ?? []
      self.showTimeSheetView()
    } errorHandler: { e in
      Toast.showMessage("There is no right time")
    }
  }
  
  func showTimeSheetView() {
    if self.bookigTimeModels.count == 0 {
      Toast.showMessage("There is no right time")
      return
    }
    Toast.dismiss()
    let strs = self.bookigTimeModels.map({  e -> String in
      let sbs = e.split(separator: ":").first ?? ""
      if String(sbs).int ?? 0 > 12 {
        return e.appending(" PM")
      }else {
        return e.appending(" AM")
      }
    })
    BookingServiceFormSheetView.show(dataArray: strs, type: .TimeSlot) { index in
      
      self.footView.setConfirmButtonIsReady(true)
      
      self.selectedTime = self.bookigTimeModels[index]
      self.models.filter({ $0.type == .timeSlot }).first?.title = strs[index]
      self.tableView?.reloadData()
      
      
    }
  }
  
  
  func getBusiness() {
    let params = SOAPParams(action: .Employee, path: .getBusiness)
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(BusinessManModel.self, from: data) {
        self.selectedEmployee = EmployeeForServiceModel()
        self.selectedEmployee?.employee_id = model.id ?? ""
        self.selectedEmployee?.employee_name = model.first_name ?? ""
      }
    } errorHandler: { e in
      
    }
    
  }
  
  func checkCanBookService(sender:LoadingButton) {
    
    let params = SOAPParams(action: .BookingOrder, path: .checkCanBookService)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    let startTime = self.selectedDate?.appending(" ").appending(self.selectedTime ?? "").appending(":00") ?? ""
    params.set(key: "startTime", value: self.selectedDate?.appending(" ").appending(self.selectedTime ?? "").appending(":00") ?? "")
    
    let duration = selectedService?.duration.int ?? 0
    let endTime = startTime.dateTime?.addingTimeInterval(TimeInterval(duration * 60)).string(withFormat: "yyyy-MM-dd HH:mm:ss") ?? ""
    params.set(key: "endTime", value: endTime)
    
    sender.startAnimation()
    NetworkManager().request(params: params) { data in
      sender.stopAnimation()
      let flag = String(data: data, encoding: .utf8)?.int ?? 1
      if flag == 0 {
        self.confirm()
      }else {
        AlertView.show(message: "Another appointment with a similar time slot has been created. Please select another day or time.")
      }
      
    } errorHandler: { e in
      sender.stopAnimation()
      AlertView.show(message: "Another appointment with a similar time slot has been created. Please select another day or time.")
    }
    
  }
  
  /// 非指定预约检查是否可以预约
  func checkRandomBookService(sender:LoadingButton) {
    let params = SOAPParams(action: .BookingOrder, path: .checkRandomBookService)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    let startTime = self.selectedDate?.appending(" ").appending(self.selectedTime ?? "").appending(":00") ?? ""
    params.set(key: "startTime", value: self.selectedDate?.appending(" ").appending(self.selectedTime ?? "").appending(":00") ?? "")
    
    let duration = selectedService?.duration.int ?? 0
    let endTime = startTime.dateTime?.addingTimeInterval(TimeInterval(duration * 60)).string(withFormat: "yyyy-MM-dd HH:mm:ss") ?? ""
    params.set(key: "endTime", value: endTime)
    
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "date", value: self.selectedDate ?? "")
    params.set(key: "gender", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
    
    sender.startAnimation()
    NetworkManager().request(params: params) { data in
      sender.stopAnimation()
      let flag = String(data: data, encoding: .utf8)?.int ?? 1
      if flag == 0 {
        self.confirm()
      }else {
        AlertView.show(message: "Unable to make an appointment in the current time period. Please select another day or time.")
      }
      
    } errorHandler: { e in
      sender.stopAnimation()
      AlertView.show(message: "Unable to make an appointment in the current time period. Please select another day or time.")
    }
    
  }
  
  func checkHasConsultation(sender:LoadingButton) {
    let params = SOAPParams(action: .BookingOrder, path: .checkConsulted)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "date", value: self.selectedDate ?? "")
    
    sender.startAnimation()
    NetworkManager().request(params: params) { data in
      sender.stopAnimation()
      let flag = String(data: data, encoding: .utf8)?.int ?? 1
      if flag == 0 {
        self.checkCanBookService(sender: sender)
      }else {
        AlertView.show(message: "Another appointment with a similar time slot has been created. Please select another day or time.")
      }
      
    } errorHandler: { e in
      sender.stopAnimation()
      AlertView.show(message: "Another appointment with a similar time slot has been created. Please select another day or time.")
    }
    
  }
  
  func getLastSymptomCheckReport() {
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
        
        self.footView.result = result
        let footerAditonalH = result.isEmpty ? 0 : 285
        self.footView.size = CGSize(width: kScreenWidth, height: 226 + footerAditonalH.cgFloat)
        self.tableView?.tableFooterView = self.footView
        
      }
      
    } errorHandler: { e in
      
    }
  }
  /*
   var time = ""
   var date = ""
   var location = ""
   
   var user_name = ""
   var user_passport = ""
   var user_gender = ""
   var user_birth_day = ""
   
   var outlet_id = ""
   var outlet_address = ""
   var remark = ""
   var service_type = ""
   var business_id = ""
   var business_name = ""
   
   var service_name = ""
   var service_id = ""
   var duration = ""
   
   var isSyncCalendar = true
   
   */
  func confirm() {
    let params = ConfirmSessionModel()
    
    params.time = self.models.filter({ $0.type == .timeSlot }).first?.title ?? ""
    params.date = self.models.filter({ $0.type == .date }).first?.title ?? ""
    params.location = self.selectCompany?.name ?? ""
    
    if let user = Defaults.shared.get(for: .userModel) {
      params.user_name = user.first_name + " " + user.last_name
      params.user_gender = user.gender == "1" ? "Male" : "Female"
      params.user_birth_day = user.birthday.date?.string(withFormat: "dd MMM yyyy") ?? ""
      params.user_passport = user.card_number
    }
    
    params.outlet_id = selectCompany?.id.string ?? ""
    params.outlet_address = selectCompany?.address ?? ""
    params.remark = self.models.filter({ $0.type == .note }).first?.title ?? ""
    params.service_type = self.type
    params.business_id = selectedEmployee?.employee_id ?? ""
    params.business_name = selectedEmployee?.employee_name ?? ""
    
    params.service_name = selectedService?.alias_name ?? ""
    params.service_id = selectedService?.id ?? ""
    params.duration = selectedService?.duration ?? ""
    
    params.isSyncCalendar = isSyncCalendar
    
    let vc = ConfirmSessionController(params: params)
    self.navigationController?.pushViewController(vc, animated: true)
    
  }
  
 
}
