//
//  ChildDeclarationModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/10/9.
//

import UIKit


class KidsMassageFields :BaseModel {
  var birth_no: String = ""
  var id: Int = 0
  var age: Int = 0
  var case_report_id: Int = 0
  var race_other: String = ""
  var weight: String = ""
  var purpose: Int = 0
  var race: Int = 0
  var birthday: String = ""
  var client_id: Int = 0
  var gender: Int = 0
  var name: String = ""
  var specify: String = ""
}

class ChildDeclarationModel :BaseModel {
  var client: Client?
  var kidsMassageFields: KidsMassageFields?
  var kidsQuestions: [HealthDeclarationModel] = []

}
