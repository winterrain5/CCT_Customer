//
//  ConfirmSessionContainer.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/25.
//

import UIKit
import EventKit
class ConfirmSessionModel {
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
  var service_type:ServiceType = .Treatment
  var business_id = ""
  var business_name = ""
  
  var service_name = ""
  var service_id = ""
  var duration = ""
  
  var isSyncCalendar = true
  
}

class ConfirmSessionContainer: UIView {

  @IBOutlet weak var employeeView: UIView!
  @IBOutlet weak var infoHCons: NSLayoutConstraint!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var employeeNameLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userPassportLabel: UILabel!
  @IBOutlet weak var userGenderLabel: UILabel!
  @IBOutlet weak var userBirthDayLabel: UILabel!
  
  @IBOutlet weak var confirmButton: LoadingButton!
  var confirmHandler:(()->())?
  
  var model:ConfirmSessionModel? {
    didSet {
      
      guard let model = model else { return }
      
      titleLabel.text = model.service_name
      timeLabel.text = model.time
      dateLabel.text = model.date
      locationLabel.text = model.location
      employeeNameLabel.text = model.business_name
      
      userNameLabel.text = model.user_name
      guard let rang = Range(NSRange(location: 0, length: 5), in: model.user_passport) else { return }
      userPassportLabel.text = model.user_passport.replacingCharacters(in: rang, with: "*****")
      userGenderLabel.text = model.user_gender
      userBirthDayLabel.text = model.user_birth_day
      
      if model.service_type == .Therapist {
        employeeView.isHidden = false
        infoHCons.constant = 172
      }else {
        employeeView.isHidden = true
        infoHCons.constant = 145
      }
      
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  var todayModel:BookingTodayModel? {
    didSet {
      guard let todayModel = todayModel else {
        return
      }
      let date = todayModel.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      titleLabel.text = todayModel.alias_name
      
      if todayModel.wellness_treatment_type == "2" { // treatment
        let sub1 = "\(todayModel.queue_count) currently in queue \nEstimated "
        let str = "\(todayModel.queue_count) currently in queue \nEstimated \(todayModel.duration_mins) mins waiting time"
        let attr = NSMutableAttributedString(string: str)
        attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size: 14), range: NSRange(location: 0, length: todayModel.queue_count.count))
        attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size: 14), range: NSRange(location: sub1.count, length: (todayModel.duration_mins + " mins").count))
        timeLabel.attributedText = attr
        employeeView.isHidden = true
        infoHCons.constant = 172
      }else{
        timeLabel.text = date?.timeString(ofStyle: .short)
        if todayModel.staff_is_random == "2" {
          employeeView.isHidden = false
          infoHCons.constant = 172
        }else {
          employeeView.isHidden = true
          infoHCons.constant = 145
        }
      }
      
      
      dateLabel.text = date?.string(withFormat: "dd MMM yyyy,EEE")
      locationLabel.text = todayModel.location_alias_name.isEmpty ? todayModel.location_name : todayModel.location_alias_name
      employeeNameLabel.text = todayModel.staff_name
      
      if let user = Defaults.shared.get(for: .userModel) {
        userNameLabel.text = user.first_name + " " + user.last_name
        guard let rang = Range(NSRange(location: 0, length: 5), in: user.card_number) else { return }
        userPassportLabel.text = user.card_number.replacingCharacters(in: rang, with: "*****")
        userGenderLabel.text = user.gender == "1" ? "Male" : "Female"
        userBirthDayLabel.text = user.birthday.date(withFormat: "yyyy-MM-dd")?.string(withFormat: "dd MMM yyyy")
      }
      
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  @IBAction func confirmAction(_ sender: LoadingButton) {
    if todayModel != nil {
      changeTStatus()
    }else {
      saveTOnlineBookingData()
    }
  }
  
  func changeTStatus() {
    // 1.保健 2.治疗 3.产前，4.产后
    let formType = todayModel?.health_declaration_form_type.int ?? 0
    
    guard let todayModel = todayModel else {
      return
    }
    
    if formType == 1 {
      let vc = HealthCareDeclarationController(bookedService: todayModel)
      UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
    }
    
    if formType == 2 {
      let vc = TreatmentDeclarationController(bookedService: todayModel)
      UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
    }
    
    if formType == 3 {
      let vc = PreConceptionDeclarationController(bookedService: todayModel)
      UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
    }
    
    if formType == 	4 {
      let vc = PostPartumDeclarationController(bookedService: todayModel)
      UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
    }
  }
  
  func saveTOnlineBookingData() {
    
    var url:API!
    guard let model = model else {
      return
    }

    switch model.service_type {
    case .Treatment:
      url = .saveDocTData
    case .DateTime:
      url = .saveAppRandonData
    case .Therapist:
      url = .saveAppAssignData
    }
    
    
    let mapParams = SOAPParams(action: .BookingOrder, path: url)
    
    let data = SOAPDictionary()
    
    let user = Defaults.shared.get(for: .userModel) ?? UserModel()
    let clientId = Defaults.shared.get(for: .clientId) ?? ""
    let client_data = SOAPDictionary()
    client_data.set(key: "client_id", value: clientId)
    client_data.set(key: "first_name", value: user.first_name)
    client_data.set(key: "last_name", value: user.last_name)
    client_data.set(key: "gender", value: user.gender)
    client_data.set(key: "birthday", value: user.birthday)
    
    data.set(key: "Client_Data", value: client_data.result, keyType: .string, valueType: .map(1))
    
    let order_info = SOAPDictionary()
    order_info.set(key: "company_id", value: model.outlet_id)
    order_info.set(key: "location_id", value: model.outlet_id)
    order_info.set(key: "client_id", value: clientId)
    order_info.set(key: "remark", value: "")
    order_info.set(key: "repeat_type", value: 0)
    let date = model.date.date(withFormat: "dd MMM yyyy,EEE")?.string(withFormat: "yyyy-MM-dd") ?? ""
    order_info.set(key: "start_date", value: date)
    order_info.set(key: "end_date", value: date)
    order_info.set(key: "create_time", value: Date().string(withFormat: "yyyy-MM-dd HH:mm:ss"))
    order_info.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
    order_info.set(key: "is_delete", value: 0)
    
    data.set(key: "Order_Info", value: order_info.result, keyType: .string, valueType: .map(1))
    
    let order_lines_infos = SOAPDictionary()
    let order_lines_info = SOAPDictionary()
    
    order_lines_info.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    order_lines_info.set(key: "location_id", value: model.outlet_id)
    order_lines_info.set(key: "client_id", value: clientId)
    order_lines_info.set(key: "booking_service_duration_id", value: model.service_id)
    order_lines_info.set(key: "book_date", value: date)
    let therapy_start_date = date.appending(" ").appending(model.time.dropLast(3)).appending(":00")
    let therapy_end_date = therapy_start_date.dateTime?.addingTimeInterval(TimeInterval((model.duration.int ?? 0) * 60)).string(withFormat: "yyyy-MM-dd HH:mm:ss") ?? ""
    order_lines_info.set(key: "therapy_start_date", value: therapy_start_date)
    order_lines_info.set(key: "therapy_end_date", value: therapy_end_date)
    order_lines_info.set(key: "duration", value: model.duration)
    order_lines_info.set(key: "work_status", value: 1)
    order_lines_info.set(key: "booking_staff_id", value: model.business_id)
    order_lines_info.set(key: "origin_staff_id", value: model.business_id)
    order_lines_info.set(key: "from", value: "app booking")
    order_lines_info.set(key: "status", value: 1)
    order_lines_info.set(key: "type", value: 1)
    order_lines_info.set(key: "has_paid", value: 0)
    
    if model.service_type == .Therapist {
      order_lines_info.set(key: "staff_is_random", value: 2)
    }else {
      order_lines_info.set(key: "staff_is_random", value: 1)
    }
    
    if model.service_type == .Treatment {
      order_lines_info.set(key: "show_in_pos", value: 0)
    }else {
      order_lines_info.set(key: "show_in_pos", value: 1)
    }
    
    order_lines_info.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
    order_lines_info.set(key: "remark", value: model.remark)
    
    order_lines_infos.set(key: "0", value: order_lines_info.result, keyType: .string, valueType: .map(1))
    
    data.set(key: "Order_lines", value: order_lines_infos.result, keyType: .string, valueType: .map(1))
    
    mapParams.set(key: "data", value: data.result, type: .map(1))
    
    let logData = SOAPDictionary()
    logData.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
    
    mapParams.set(key: "logData", value: logData.result,type: .map(2))
   
    confirmButton.startAnimation()
    NetworkManager().request(params: mapParams) { data in
      self.newCreateAppointment()
    } errorHandler: { e in
      self.confirmButton.stopAnimation()
    }

  }
  
  func newCreateAppointment() {
    guard let model = model else {
      return
    }

    let params = SOAPParams(action: .Notifications, path: .newCreateAppointment)
    params.set(key: "service", value: model.service_name)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
     
    } errorHandler: { e in
      self.showSuccessSheet()
      self.confirmButton.stopAnimation()
    }
    self.getTSystemConfig()
    self.addToCalendar()
    NotificationCenter.default.post(name: .bookingDataChanged, object: nil)
  }
  
  func getTSystemConfig() {
    let params = SOAPParams(action: .SystemConfig, path: .getTSystemConfig,isNeedToast: false)
    params.set(key: "cmpanyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(SystemConfigModel.self, from: data) {
        self.sendSmsForEmail(model)
      }
    } errorHandler: { e in
      self.showSuccessSheet()
      self.confirmButton.stopAnimation()
    }

  }
  
  func sendSmsForEmail(_ config:SystemConfigModel) {
    guard let model = model else {
      return
    }

    let mapParams = SOAPParams(action: .Sms, path: .sendSmsForEmail,isNeedToast: false)
    
    let data = SOAPDictionary()
    data.set(key: "title", value: "[Chien Chi Tow]")
    data.set(key: "email", value: Defaults.shared.get(for: .userModel)?.email ?? "")
    
    var message = "<p>Your appointment for " + model.service_name + " at " + model.location + " has been confirmed for " + model.date + " " + model.time  + "."
    message += "Please arrive 10 minutes before your appointment to perform a check-in before your appointment.</p>";
    message += "<p>" + model.outlet_address + "</P>"
    message += "<p>For more information, you can contact us at 62 933 933<p>"
    message = message.replacingOccurrences(of: "&", with: "&amp;")
    message = message.replacingOccurrences(of: "<", with: "&lt;")
    message = message.replacingOccurrences(of: ">", with: "&gt;")
    
    data.set(key: "message", value: message)
    data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    data.set(key: "from_email", value: config.send_specific_email ?? "")
    data.set(key: "client_id", value: 0)
    
    mapParams.set(key: "params", value: data.result,type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      self.showSuccessSheet()
    } errorHandler: { e in
      self.showSuccessSheet()
      self.confirmButton.stopAnimation()
    }

  }
  
  func showSuccessSheet() {
    let atttr = NSMutableAttributedString(string: "Your appointment has been confirmed !")
    AlertView.show(message: atttr, messageAlignment: .left) {
      self.confirmHandler?()
    }
  }
  
  @IBAction func noticeActio(_ sender: Any) {
    DataProtectionSheetView.show()
  }
  
  func addToCalendar() {
    guard let model = model else {
      return
    }

    if !model.isSyncCalendar { return }
    let eventStore = EKEventStore()
    eventStore.requestAccess(to: .event) { flag, e in
      if flag {
        DispatchQueue.main.async {
          let event = EKEvent(eventStore: eventStore)
          event.title = model.service_name
          
          let date = model.date.date(withFormat: "dd MMM yyyy,EEE")?.string(withFormat: "yyyy-MM-dd") ?? ""
          let therapy_start_date = date.appending(" ").appending(model.time.dropLast(3)).appending(":00")
          let therapy_end_date = therapy_start_date.dateTime?.addingTimeInterval(TimeInterval((model.duration.int ?? 0) * 60)).string(withFormat: "yyyy-MM-dd HH:mm:ss") ?? ""
          event.startDate = therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
          event.endDate = therapy_end_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
          event.notes = model.remark
          event.calendar = eventStore.defaultCalendarForNewEvents
          let alarm = EKAlarm(absoluteDate: event.startDate.addingTimeInterval(-60 * 60))
          event.addAlarm(alarm)
          event.location = model.outlet_address
          
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
