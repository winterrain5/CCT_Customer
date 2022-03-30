//
//  MyOrderModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class OrderLines :Codable {
  var qty: String?
  var name: String?
  
}

class MyOrderModel: Codable {
  var remark: String?
  var id: String?
  var order_lines: [OrderLines]?
  var type: String?
  var invoice_no: String?
  var invoice_date: String?
  
}
