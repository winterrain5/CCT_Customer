//
//  SymptomCheckPlanModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/17.
//

import UIKit

class SymptomCheckPlanModel: Codable {
  
  var part_one_duration: String?
  var part_one_description: String?
  var part_one_retail_price: String?
  var part_one_title: String?
  
  var part_two_title: String?
  var part_two_description: String?
  
  var part_three_title: String?
  var part_three_description: String?
  
  var overview_description: String?
  var title: String?
  
  var complicated_retail_price: String?
  var service_duration_id: String?

  var complicated_img: String?
  var complicated_duration: String?
  var complicated_description: String?
  
  var interelated_duration: String?
  var interelated_description: String?
  var interelated_retail_price: String?
  var interelated_img: String?
  
  var targeted_description: String?
  var targeted_duration: String?
  var targeted_retail_price: String?
  var targeted_service_duration_id: String?
  var targeted_img: String?
  
  var question3_id: String?
  var id: String?
  var interelated_service_duration_id: String?
  var complicated_service_duration_id: String?
  var is_delete: String?
  var question2_id: String?
  
  // 0 
  var type:Int?
  
}

