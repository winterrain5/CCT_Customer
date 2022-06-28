//
//  WalletVouchersModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit
import HandyJSON
class WalletVouchersModel:BaseModel, Codable {
  var id: String?
  var gift_id: String?
  var create_date: String?
  var desc: String?
  var balance: String?
  var voucher_id: String?
  var is_delete: String?
  var last_use_date: String?
  var remark: String?
  var client_id: String?
  var nominal_value: String?
  var name: String?
  var isSelected = false
  func mapping(mapper: HelpingMapper) {
    mapper <<<
      self.desc <-- "description"
  }
}
