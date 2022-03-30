//
//  BlogDetailModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/7.
//

import UIKit

class BlogDetailModel: Codable {
  var id: String?
  var is_featured: String?
  var filter_keys: String?
  var filters: [BlogFilterLabel]?
  var location_name: String?
  var thumbnail_img: String?
  var company_id: String?
  var change_time: String?
  var release_location: String?
  var title: String?
  var cct_or_mp: String?
  var is_delete: String?
  var category_type_id: String?
  var create_time: String?
  var content: String?
  var has_booked: Bool?
  var video_url:String?
}
