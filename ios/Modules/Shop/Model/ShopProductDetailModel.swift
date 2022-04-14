//
//  ShopDetailModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/13.
//

import UIKit

class Product :BaseModel {
  var avg_rating: String = "0"
  var alias: String = ""
  var on_hand: String = ""
  var id: String = ""
  var product_category: Int = 0
  var picture: String = ""
  var sell_price: String = ""
  var how_help: String = ""
  var how_to_use: String = ""
  var name: String = ""
  var suitable_for_who: String = ""
  var count = 1
}

class Reviews :BaseModel {
  var id: String = ""
  var last_name: String = ""
  var review_content: String = ""
  var create_time: String = ""
  var first_name: String = ""
  var rating: String = "0"
//
}

class Counts :BaseModel {
  var counts: String = ""
  
}

class ShopProductDetailModel :BaseModel {
  var Product: Product?
  var Reviews: [Reviews] = []
  var Counts: Counts?
  
}
