//
//  WalletPaymentMethodModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit

class MethodLines :Codable {
  var card_number: String?
  var id: String?
  var authorisation_code: String?
  var name_on_card: String?
  var expiry_date: String?
  var isSelected:Bool?
}

class WalletPaymentMethodModel :Codable {
  var method_type: String?
  var id: String?
  var company_id: String?
  var create_date: String?
  var create_uid: String?
  var method_lines: [MethodLines]?
  var payment_method: String?
  
}
