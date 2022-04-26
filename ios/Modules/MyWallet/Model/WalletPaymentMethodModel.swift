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
  
  // 本地字段
  var isSelected:Bool?
  //
  var amount: String = ""
  /// 0：会员卡， 1 朋友的卡，2 自己的信用卡
  var type:Int = 1
  var trans_limit:String = "0"
  var card_owner_id:String = ""
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
