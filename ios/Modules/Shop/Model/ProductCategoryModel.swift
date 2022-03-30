//
//  ProductCategoryModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/9.
//

import UIKit


class SubNodes :Codable {
  
}

class ProductCategoryModel :Codable {
  var id: Int?
  var company_id: Int?
  var can_sell: Int?
  var create_uid: Int?
  var subNodes: [SubNodes]?
  var is_show: Int?
  var is_delete: Int?
  var productCount: String?
  var pid: Int?
  var sort: Int?
  var create_time: String?
  var name: String?
  
}
