//
//  ConfirmSessionContainer.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/25.
//

import UIKit

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

  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userPassportLabel: UILabel!
  @IBOutlet weak var userGenderLabel: UILabel!
  @IBOutlet weak var userBirthDayLabel: UILabel!
  
  @IBOutlet weak var confirmButton: LoadingButton!
  var confirmHandler:(()->())?
  
  var model:ConfirmSessionModel! {
    didSet {
      timeLabel.text = model.time
      dateLabel.text = model.date
      locationLabel.text = model.location
      
      userNameLabel.text = model.user_name
      guard let rang = Range(NSRange(location: 0, length: 5), in: model.user_passport) else { return }
      userPassportLabel.text = model.user_passport.replacingCharacters(in: rang, with: "*****")
      userGenderLabel.text = model.user_gender
      userBirthDayLabel.text = model.user_birth_day
    }
  }
  
  
  @IBAction func confirmAction(_ sender: LoadingButton) {
    
    saveTOnlineBookingData()
    
  }
  
  func saveTOnlineBookingData() {
    
    var url = API.saveTOnlineBookingData
    if model.service_type == .Treatment {
      url = .saveDocTData
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
    order_info.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
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
    let therapy_end_date = therapy_start_date.dateTime?.addingTimeInterval(TimeInterval(model.duration.int ?? 0)).string(withFormat: "yyyy-MM-dd HH:mm:ss") ?? ""
    order_lines_info.set(key: "therapy_start_date", value: therapy_start_date)
    order_lines_info.set(key: "therapy_end_date", value: therapy_end_date)
    order_lines_info.set(key: "duration", value: model.duration)
    order_lines_info.set(key: "work_status", value: 1)
    order_lines_info.set(key: "booking_staff_id", value: model.business_id)
    order_lines_info.set(key: "origin_staff_id", value: model.business_id)
    order_lines_info.set(key: "from", value: "app booking")
    order_lines_info.set(key: "status", value: 1)
    order_lines_info.set(key: "type", value: 1)
    order_lines_info.set(key: "has_pid", value: 0)
    
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
    
    order_lines_info.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
    order_lines_info.set(key: "remark", value: model.remark)
    
    order_lines_infos.set(key: "0", value: order_lines_info.result, keyType: .string, valueType: .map(1))
    
    data.set(key: "Order_lines", value: order_lines_infos.result, keyType: .string, valueType: .map(1))
    
    mapParams.set(key: "data", value: data.result, type: .map(1))
    
    let logData = SOAPDictionary()
    logData.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
    
    mapParams.set(key: "logData", value: logData.result,type: .map(2))
   
    confirmButton.startAnimation()
    NetworkManager().request(params: mapParams) { data in
      self.newCreateAppointment()
    } errorHandler: { e in
      self.confirmButton.stopAnimation()
    }

  }
  
  func newCreateAppointment() {
    let params = SOAPParams(action: .Notifications, path: .newCreateAppointment)
    params.set(key: "service", value: model.service_name)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      self.getTSystemConfig()
    } errorHandler: { e in
      self.confirmButton.stopAnimation()
    }

  }
  
  func getTSystemConfig() {
    let params = SOAPParams(action: .SystemConfig, path: .getTSystemConfig,isNeedToast: false)
    params.set(key: "cmpanyId", value: Defaults.shared.get(for: .companyId) ?? "")
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
    data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "")
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
      UIViewController.getTopVc()?.navigationController?.popToRootViewController(animated: true)
    }
  }
  
  @IBAction func noticeActio(_ sender: Any) {
    DataProtectionSheetView.show()
  }
}
