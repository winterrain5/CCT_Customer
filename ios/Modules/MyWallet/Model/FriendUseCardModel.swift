//
//  FriendUseCardModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/6.
//

import Foundation
class FriendUseTransActions :Codable {
  var paid_amount: String?
  var product_category: String?
  var name: String?
  var close_time: String?
  
}

class FriendUseCardModel :Codable {
  var date: String?
  var transActions: [FriendUseTransActions]?
  
}
