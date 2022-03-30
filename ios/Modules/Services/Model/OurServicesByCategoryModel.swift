//
//  OurServicesByCategoryModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import UIKit


class ServiceDuration :Codable {
  var min_price: String?
  var max_duration: String?
  var min_duration: String?
  var max_price: String?
}

class OurServicesByCategoryModel :Codable {
  var approaches: [ServiceApproaches]?
  var approach_types: String?
  var id: String?
  var service_description: String?
  var part1_thumbnail_img: String?
  var name: String?
  var service_duration: ServiceDuration?
}

