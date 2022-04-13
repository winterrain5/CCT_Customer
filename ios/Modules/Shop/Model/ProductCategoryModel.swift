//
//  ProductCategoryModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/9.
//

import UIKit


class SubNodes :BaseModel {
  
}

@objcMembers class ProductCategoryModel :BaseModel {
  var id: String = ""
  var company_id: String = ""
  var can_sell: String = ""
  var create_uid: String = ""
  var subNodes: [SubNodes]?
  var is_show: String = ""
  var is_delete: String = ""
  var productCount: String = ""
  var pid: String = ""
  var sort: String = ""
  var create_time: String = ""
  var name: String = ""
  
}
