//
//  BookingServiceModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/23.
//

import UIKit

class BookingServiceModel: BaseModel {
  var caption = ""
  var id = ""
  var service_description = ""
  var service_id = ""
  var duration = ""
  /// 1.保健 2.治疗 3.产前， 4.产后
  var health_declaration_form_type = 0
  var alias_name = ""
}
