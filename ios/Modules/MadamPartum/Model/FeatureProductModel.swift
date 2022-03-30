//
//  FeatureProductModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/20.
//

import UIKit

class FeatureProductModel: Codable {
  var id:String?
  var name:String? // 中文名
  var is_featured:String?
  var is_new:String?
  var sell_price:String?
  var avg_rating:String?
  var picture:String?
  var isLike:Bool?
  var alias:String? // 英文名
}
