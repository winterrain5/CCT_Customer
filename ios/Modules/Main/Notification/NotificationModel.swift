//
//  NotificationModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/9.
//

import UIKit

class NotificationModel: BaseModel {
  var friend_id = ""
  var booking_id = ""
  var category = ""
  var content = ""
  var id = ""
  var send_date = ""
  var title = ""
  var owner_id = ""
  /// 0：未审核 1：同意 2：拒绝
  /// owner_id不为 0 且 auth_status 为0  展示操作按钮
  var auth_status = ""
  // 1为已读 
  var is_read = ""
  var isSelected = false
  var isToDay:Bool {
    let date = send_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
    return date?.isInToday ?? false
  }
  var formatDate:String {
    let date = send_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
    if date?.isInToday ?? false {
     
      let hour = Date().hoursSince(date!).int
      let min = Date().minutesSince(date!).int
      let second = Date().secondsSince(date!).int
      if hour > 0 {
        return hour.string.appending("h ago")
      }
      if hour == 0 && min > 0 {
        return min.string.appending("m ago")
      }
      if hour == 0 && min == 0 && second > 0{
        return second.string.appending("s ago")
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
