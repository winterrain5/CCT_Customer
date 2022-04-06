//
//  CardPrivilegesModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

class CardPrivilegesModel: Codable {
  var id: String?
  var sale_category_title: String?
  var service_category: String?
  var sale_category: String?
  var version: String?
  var recharge_card_level: String?
  var discount_percent: String?
  
}

class CardDiscountDetailModel: Codable {
  var r_discount2: String?
  var id: Int?
  var level: Int?
  var r_discount1: String?
  var is_delete: String?
  var r_discount3: String?
  var create_time: String?
}
