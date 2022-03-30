//
//  WalletTranscationModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/3.
//

import UIKit

class Payments :Codable {
  var payment_method: String?
  var paid_amount: String?
  
}

class WalletTranscationModel: Codable  {
  var due_date: String?
  var alias_name: String?
  var status: String?
  var location_name: String?
  var invoice_date: String?
  var total: String?
  var paid_amount: String?
  var present_points: String?
  var customer_id: String?
  var last_name: String?
  var payments: [Payments]?
  var balance: String?
  var first_product_name: String?
  var type: String?
  var product_name: String?
  var id: String?
  var invoice_no: String?
  var subtotal: String?
  var freight: String?
  var sales_type_name: String?
  var first_name: String?
  var remark: String?
  var product_category: String?
  
}
