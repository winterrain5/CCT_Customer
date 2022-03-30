//
//  ServiceBrifeModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit

struct BriefHelpItems :Codable {
  var title: String?
  var thumbnail_img: String?
  var description: String?
}

class ServiceBriefData :Codable {
  var id: Int?
  var how_help_title: String?
  var last_thumbnail_img: String?
  var treatment_plan_id: Int?
  var do_what: String?
  var summary_desc: String?
  var do_what_title: String?
  var title: String?
  var for_what_title: String?
  var is_delete: Int?
  var how_help_items: String?
  var for_what: String?
  var part1_thumbnail_img: String?
  var create_time: String?
  
}

struct ServiceApproaches :Codable {
  var title: String?
  var thumbnail_img: String?
  var description: String?
}

class ServiceDurations :Codable {
  var retail_price: String?
  var duration: String?
  
}

class ServiceDetailBrifeModel :Codable {
  var briefHelpItems: [BriefHelpItems]?
  var briefData: ServiceBriefData?
  var approaches: [ServiceApproaches]?
  var durations: [ServiceDurations]?
  
}
