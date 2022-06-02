//
//  BlogModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import UIKit

class BlogFilterLabel :BaseModel,Codable {
  var id: String?
  var key_word: String?
  var is_on: Bool?
}

class BlogModel :BaseModel,Codable {
  var id: String?
  var is_featured: String?
  var filter_keys: String?
  var thumbnail_img: String?
  var location_name: String?
  var filters: [BlogFilterLabel]?
  var company_id: String?
  var release_location: String?
  var title: String?
  var change_time: String?
  var is_delete: String?
  var cct_or_mp: String?
  var category_type_id: String?
  var create_time: String?
  var has_booked: Bool = false
  
}
