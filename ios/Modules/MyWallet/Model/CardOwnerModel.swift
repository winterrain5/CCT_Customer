//
//  CardOwnerModekl.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

class CardOwnerModel: BaseModel,Codable {
  
  var mobile: String?
  var friend_id: String?
  var id: String?
  var card_owner_id: String?
  var last_name: String?
  var trans_limit: String?
  var first_name: String?
  
  var new_recharge_card_period = ""
  var new_recharge_card_level_text = ""
  
  var desc: String?
  var exceed_value: String?
  var expired_time: String?
  var create_date: String?
  var balance: String?
  var img: String?
  var value_type: String?
  var can_use_date_type: String?
  var client_id: String?
  var nominal_value: String?
  var name: String?
  
  var new_card_amount:CGFloat?
  
  /// 是否是朋友的卡
  var isFriendCard:Bool?
  
  
  
}

