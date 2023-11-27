//
//  BookingCompleteModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/16.
//

import UIKit

class BookingCompleteModel: BookingBaseModel {
  var alias_name: String = ""
  var therapy_start_date: String = ""
  var start_time: String = ""
  var id: String = ""
  var duration: String = ""
  var source_id: String = ""
  var name: String = ""
  var items: [String] = []
  
  
  var date:Date? {
    var date:Date?
    if let start_time = start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss") {
     date = start_time
    } else {
     date = therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
    }
    return date
  }

}
