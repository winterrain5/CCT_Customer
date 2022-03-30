//
//  SymptomCheckReportModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/14.
//

import UIKit

class SymptomCheckReportModel: Codable {
  var best_describes_qa_title: String?
  var pain_areas_qa_ids: String?
  var symptoms_qa_id: String?
  var id: String?
  var best_describes_qa_id: String?
  var symptoms_qas: [SymptomsQas]?
  var pain_areas: [PainAreas]?
  var fill_date: String?
}
class SymptomsQas :Codable {
  var title: String?
  var id: String?
}

class PainAreas :Codable {
  var title: String?
  var id: String?
}

