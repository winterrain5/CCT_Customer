//
//  WellnessAppointmentController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/20.
//

import UIKit
import EventKit
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
  case Treatment // 看诊
  case DateTime // 服务（日期）
  case Therapist // 服务 （人员）
}

class BookingAppointmentController: BaseTableController {
 
  
  var headLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 24)
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
  
  var footerAditonalH:CGFloat = 0
  
  convenience init(type: ServiceType, result:[Int:[SymptomCheckStepModel]]) {
    self.init()
    self.type = type
    self.result = result
    footerAditonalH = result.isEmpty ? 0 : 285
  }
  
  convenience init(type: ServiceType) {
    self.init()
    self.type = type
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
    self.view.backgroundColor = R.color.theamBlue()
    headView.addSubview(headLabel)
    headLabel.text = type == .DateTime ? "Select By Preferred Slot" : "Select By Preferred Therapist"
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
   
    
    getBusiness()
  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    tableView?.separatorStyle = .singleLine
    
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: 84)
    
    tableView?.tableFooterView = footView
    footView.footerView.isHidden = true
    footView.size = CGSize(width: kScreenWidth, height: 200 + footerAditonalH)
    footView.syncCalendar = { [weak self]  isSelect in
      self?.isSyncCalendar = isSelect
    }
    footView.confirmHandler = { [weak self] sender in
      self?.checkCanBookService(sender: sender)
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
    if selectedService == nil {
      Toast.showMessage("Please Select a Service")
      return
    }
    if type == .Therapist {
      if selectedEmployee == nil {
        Toast.showMessage("Please Select a Therapist")
        return
      }
    }
    getDocSchedulesForService()
  }
  @objc func selectTimeSlot() {
    if selectCompany == nil {
      Toast.showMessage("Please Select a outlet")
      return
    }
    if selectedService == nil {
      Toast.showMessage("Please Select a Service")
      return
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
    getBokingTimeSlots()
  }
  
  
  
  func getCanOnlineBookingLocation() {
    
    Toast.showLoading()
    
    let params = SOAPParams(action: .Company, path: .getCanOnlineBookingLocations)
    params.set(key: "pId", value: Defaults.shared.get(for: .companyId) ?? "")
    
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
    }
  }
  
  func getServiceByLocation() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getServicesByLocation)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "isWellness", value: "1")
    params.set(key: "gendar", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingServiceModel.self, from: data) {
        self.serviceModels = models
        
        if self.serviceModels.count == 0 {
          Toast.showMessage("No siutable service")
          return
        }
        self.showServiceSheetView()
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
    let params = SOAPParams(action: .Schedule, path: .getEmployeeForService)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    params.set(key: "gender", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      if let models = DecodeManager.decodeArrayByHandJSON(EmployeeForServiceModel.self, from: data) {
        self.employeeModels = models
        self.showEmployeeSheetView()
      }
    } errorHandler: { e in
      Toast.dismiss()
    }

    
  }
  
  func showEmployeeSheetView() {
    let strs = self.employeeModels.map({ $0.employee_name + "(\($0.gender == 1 ? "Male" : "Female"))" })
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
      
      
      self.tableView?.reloadData()
    }
  }
  
  func getBokingTimeSlots() {
    Toast.showLoading()
    let params = SOAPParams(action: .Schedule, path: .getBookingTimeSlots)
    params.set(key: "locationId", value: selectCompany?.id ?? "")
    params.set(key: "serviceId", value: selectedService?.id ?? "")
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "")
    params.set(key: "date", value: self.selectedDate ?? "")
    params.set(key: "employeeId", value: selectedEmployee?.employee_id ?? "")
    params.set(key: "isWellness", value: "1")
    
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
  
  func addToCalendar() {
    let eventStore = EKEventStore()
    eventStore.requestAccess(to: .event) { flag, e in
      if flag {
        DispatchQueue.main.async {
          let event = EKEvent(eventStore: eventStore)
          event.title = self.selectedService?.alias_name ?? ""
          event.startDate = self.selectedDate?.appending(" ").appending(self.selectedTime ?? "").date(withFormat: "yyyy-MM-dd HH:mm")
          event.endDate = self.selectedDate?.appending(" ").appending("23:59").date(withFormat: "yyyy-MM-dd HH:mm")
          event.notes = self.models.last?.title ?? ""
          event.calendar = eventStore.defaultCalendarForNewEvents
          
          do {
            try eventStore.save(event, span: .thisEvent)
          }catch{
            print(e?.localizedDescription ?? "")
          }
        }
      }
    }
  }
  
}
