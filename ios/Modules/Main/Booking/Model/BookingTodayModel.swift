//
//  BookingTodayModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/18.
//

import UIKit

class BookingTodayModel: BaseModel {
  var id: String = ""
  var room_id: String = ""
  var caption: String = ""
  var filled_health_form: Bool = false
  var health_declaration_form_type: String = ""
  var queue_no: String = ""
  var duration_mins = ""
  var queue_count: String = ""
  var location_name: String = ""
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
  var cellHeight:CGFloat {
    if status == 4 && filled_health_form {
      return 164
    }
    if !queue_no.isEmpty {
      return 225
    }
    if staff_is_random == "2" {
      return 196 + 28
    }else {
      return 196
    }
  }
}
