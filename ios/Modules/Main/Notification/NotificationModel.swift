//
//  NotificationModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/9.
//

import UIKit

class NotificationModel: BaseModel {
  var category = ""
  var content = ""
  var id = ""
  var send_date = ""
  var title = ""
  var isSelected = false
  var isToDay:Bool {
    let date = send_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
    return date?.isInToday ?? false
  }
  var formatDate:String {
    let date = send_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
    if date?.isInToday ?? false {
     
      let hour = Date().hoursSince(date!)
      let min = Date().minutesSince(date!)
      let second = Date().secondsSince(date!)
      if hour > 0 {
        return hour.int.string.appending("h ago")
      }
      if hour == 0 && min > 0 {
        return min.int.string.appending("m ago")
      }
      if hour == 0 && min == 0 && second > 0{
        return second.int.string.appending("s ago")
      }
    }else {
      if date?.isInYesterday ?? false{
        return "Yesterday"
      }else {
        return date?.string(withFormat: "d MMM") ?? ""
      }
    }
    return ""
  }
  
}
