//
//  WalletPaymentMethodModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit

class MethodLines :BaseModel,Codable {
  var card_number: String?
  var id: String?
  var authorisation_code: String?
  var name_on_card: String?
  var expiry_date: String?
  var isSelected:Bool?
  //
  var amount: String = ""
  /// 0 自己的余额 1 自己的信用卡 2 朋友的卡
  var type:Int = 1
}

class WalletPaymentMethodModel :BaseModel,Codable {
  var method_type: String?
  var id: String?
  var company_id: String?
  var create_date: String?
  var create_uid: String?
  var method_lines: [MethodLines]?
  var payment_method: String?
}
