//
//  WalletCouponsModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit
import HandyJSON
class WalletCouponsModel:BaseModel, Codable {
  var id: String?
  var desc: String?
  var create_date: String?
  var expired_time: String?
  var exceed_value: String?
  var mobile: String?
  var balance: String?
  var img: String?
  var value_type: String?
  var first_name: String?
  var can_use_date_type: String?
  var nominal_value: String?
  var client_id: String?
  var last_name: String?
  var name: String?
  var isSelected = false
  
  func mapping(mapper: HelpingMapper) {
    mapper <<<
      self.desc <-- "description"
  }
}
