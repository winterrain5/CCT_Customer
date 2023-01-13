//
//  PostPartumModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit
import HandyJSON
enum DeclarationFormType:String,HandyJSONEnum {
  case DeliveryDate
  case DeliveryMethod
  case Remark
  case Input
  case InputWithOptions
  case FocusArea
  case ChildGender
  case ChildBirthDate
  case ChildRace
  case PurposeOfDeclaration
}
enum InputContentType:String,HandyJSONEnum {
  case PregnancyWeeks
  case GynecologistName
  case GynecologistPhone
  case HighRiskReason
  case ComplicationsProblems
  case ChildName
  case ChildAge
  case ChildCertNo
  case ChildWeight
  case Specify
  case Pregnancies   
}
enum KeyboardType:String,HandyJSONEnum {
  case Number
  case Alphabet
}
class HealthDeclarationModel :BaseModel {
  var category: String = ""
  var result: String = "3"
  var sort: String = ""
  var id: String = ""
  var desc: String = ""
  var type: String = ""
  var description_en: String = ""
  
  var company_id: String = ""
  var is_delete: String = ""
  var create_uid: String = ""
  var create_time: String = ""
  var s_class: String = ""
  
  /// 以下为自定义字段
  var delivery_date = ""
  var child_birth_date = ""
  var mehtod_of_delivery = ""
  var remark = ""
  var text = ""
  var placeholder = ""
  
  // 产前问题
  var inputType:InputContentType?
  var focus_on_head:Int = 0
  var focus_on_legs:Int = 0
  var focus_on_shoulders:Int = 0
  var focus_on_arms:Int = 0
  var focus_on_neck:Int = 0
  var focus_on_back:Int = 0
 
  var formType:DeclarationFormType?
  
  var keyboardType: KeyboardType = .Alphabet
  
  var index = 1
  var questionNum: String {
    get {
      index < 10 ? "Question 0\(index)" : "Question \(index)"
    }
  }
}

class Client :BaseModel {
  var id: String = ""
  var last_name: String = ""
  var first_name: String = ""
  var address: String = ""
  
}

class PostPartumFields :BaseModel {
  var delivery_method: Int = 0
  var corset_size: String = ""
  var id: Int = 0
  var is_need_corset: Int = 0
  var case_report_id: Int = 0
  var delivery_actual_date: String = ""
  var is_need_slimming_oil: Int = 0
  var no_of_sessions: String = ""
  var delivery_estimated_date: String = ""
  
}

class PostPartumModel : BaseModel {
  var xgQuestions: [HealthDeclarationModel] = []
  var client: Client?
  var postPartumFields: PostPartumFields?
  
}
