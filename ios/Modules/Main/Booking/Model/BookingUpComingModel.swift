//
//  BookingUpComingModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/17.
//

import UIKit

class BookingUpComingModel: BaseModel{
  
  var alias_name: String = ""
  var status: String = ""
  var total: String = ""
  var therapy_start_date: String = ""
  var location_name: String = ""
  var duration: String = ""
  var service_name: String = ""
  var wellness_treatment_type: String = ""
  var retail_price: String = ""
  var staff_is_random: String = ""
  var payment_method: String = ""
  var location_id: String = ""
  var sale_order_id: String = ""
  var employee_id: String = ""
  var caption: String = ""
  var id: String = ""
  var type: String = ""
  var subtotal: String = ""
  var employee_first_name: String = ""
  var employee_code: String = ""
  var tax_id: String = ""
  var start_time: String = ""
  var employee_last_name: String = ""
  var rate: String = ""
  var remark: String = ""
  
  var cellHeight:CGFloat {
    if staff_is_random == "2" {
      return 186
    }else {
      return 160
    }
  }
  
}
