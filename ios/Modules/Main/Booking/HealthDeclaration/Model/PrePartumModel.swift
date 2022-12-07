//
//  PrePartumModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/16.
//

import UIKit

class PrePartumFields :BaseModel {
  var physician_aware_you: String?
  var pregnancy_weeks: String?
  var has_any_complications: Int = 0
  var is_first_pregnancy: Int = 0
  var focus_on_abdomen: String?
  var focus_on_head: Int = 0
  var high_risk_reasons: String?
  var focus_on_arms: Int = 0
  var is_first_massage: Int = 0
  var case_report_id: Int = 0
  var focus_on_shoulders: Int = 0
  var focus_on_back: Int = 0
  var complications_problems: String?
  var focus_on_legs: Int = 0
  var id: Int = 0
  var delivery_estimated_date: String?
  var name_phone_gynecologist: String?
  var has_high_risk: Int = 0
  var focus_on_neck: Int = 0
  var pregnancies: String?
  
}



class PrePartumModel :BaseModel {
  var prePartumFields: PrePartumFields?
  var client: Client?
  var xgQuestions: [HealthDeclarationModel] = []
  
}
