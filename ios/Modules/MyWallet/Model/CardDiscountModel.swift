//
//  CardDiscountModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/15.
//

import UIKit

class CardDiscountModel: BaseModel, Codable {
  var discount_percent:String?
  var id:String?
  var recharge_card_level:String?
  var sale_category:String?
  var sale_category_title:String?
  var service_category:String?
}
