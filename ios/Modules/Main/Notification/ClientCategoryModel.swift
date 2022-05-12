//
//  ClientCategoryModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/9.
//

import UIKit

class ClientCategoryModel: BaseModel {
  var status = 0
  var models:[NotificationCategoryModel] = []
}

class NotificationCategoryModel: BaseModel {
  var status = ""
  var id = ""
  var category_id = ""
  var client_id = ""
  var category_name = ""
}
