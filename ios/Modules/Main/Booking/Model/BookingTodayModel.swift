//
//  BookingTodayModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/18.
//

import UIKit

class BookingTodayModel: BaseModel {
  var id: String = ""
  var booking_order_time_id = ""
  var room_id: String = ""
  var caption: String = ""
  var filled_health_form: Bool = false
  var health_declaration_form_type: String = ""
  var queue_no: String = ""
  var duration_mins = ""
  var queue_count: String = ""
  var location_name: String = ""
  var location_alias_name: String = ""
  var booking_staff_id: String = ""
  var location_id: String = ""
  var therapy_start_date: String = ""
  var staff_is_random: String = ""
  var remark: String = ""
  var booking_order_id: String = ""
  var alias_name: String = ""
  var staff_name: String = ""
  var wellness_treatment_type: String = ""
  var status: Int = 0
  var wellness_or_treatment: String = ""
  var address: String = ""
  var work_status = ""
  var gender = ""
  var cellHeight:CGFloat {
    if status == 4 && wellness_or_treatment == "2" {
      return 250
    }
    
    if status == 4 && wellness_or_treatment != "2" {
      if staff_is_random == "2" {
        return 212
      }else {
        return 185
      }
    }
   
    if staff_is_random == "2" {
      return 196 + 28
    }else {
      return 196
    }
  }
}
