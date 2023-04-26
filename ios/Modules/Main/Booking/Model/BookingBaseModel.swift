//
//  BookingBaseModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2023/3/28.
//

import UIKit

class BookingBaseModel: BaseModel {
  var street_name:String = ""
  var unit_num:String = ""
  var post_code:String = ""
  var building_block_num:String = ""
  var address: String = ""
  var work_status = ""
  var location_name: String = ""
  var location_alias_name: String = ""
  var gender = ""
  var genderImage:UIImage? {
    return gender == "1" ? R.image.booking_user() : R.image.woman()
  }
  var genderColor:UIColor? {
    return gender == "1" ? kManFontColor : kWomanFontColor
  }
  
  var final_address: String {
    if work_status == "2" { // 外出
      if !building_block_num.isEmpty || !street_name.isEmpty || !unit_num.isEmpty {
        return building_block_num + " " + street_name + " " + unit_num
      }
      return address
    }else {
      return location_alias_name.isEmpty ? location_name : location_alias_name
    }
  }
}
