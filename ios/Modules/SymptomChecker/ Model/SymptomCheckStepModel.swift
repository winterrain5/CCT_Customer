//
//  SymptomCheckStepModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckStepModel:BaseModel, Codable {
  var isSelected:Bool?
  var id: String?
  var title: String?
  var question_category: String?
}
