//
//  BlogBookmarkedModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/11.
//

import UIKit

class BlogBookmarkedModel: Codable {
  var change_time: String?
  var location_name: String?
  var filter_keys: String?
  var id: String?
  var is_featured: String?
  var title: String?
  var thumbnail_img: String?
  var category_type_id: String?
  var create_time: String?
  var category_type: String?
  var filter_labels:[BlogFilterLabel]?
  var has_booked:Bool?
}
