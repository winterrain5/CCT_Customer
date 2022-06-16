//
//  PostPartumModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit

class HealthDeclarationModel :BaseModel {
  var category: String = ""
  var result: String = "3"
  var sort: String = ""
  var id: String = ""
  var desc: String = ""
  ///  date method remark  属于自定义
  var type: String = ""
  var description_en: String = ""
  
  var company_id: String = ""
  var is_delete: String = ""
  var create_uid: String = ""
  var create_time: String = ""
  var s_class: String = ""
  
  var date = ""
  var mehtod_of_delivery = ""
  var remark = ""
  
  var index = 1
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
