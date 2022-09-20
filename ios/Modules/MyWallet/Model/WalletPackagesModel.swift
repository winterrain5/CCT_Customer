//
//  WalletPackagesModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/8/9.
//

import UIKit
import HandyJSON
class Item :BaseModel {
  var voucher_code: String = ""
  var name: String = ""
  var balance: String = ""
  var voucher_type: String = ""
  
}

class WalletPackagesModel :BaseModel {
  var name: String = ""
  var alias: String = ""
  var expiry_period_date: String = ""
  var create_date: String = ""
  var thumbnail_img: String = ""
  var desc: String = ""
  var type: String = ""
  var item: [Item] = []
  var sale_order_line_id: String = ""
  func mapping(mapper: HelpingMapper) {
    mapper <<<
      self.desc <-- "description"
  }
}
