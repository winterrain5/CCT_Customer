//
//  RegistUserInfoModel.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/9.
//

import UIKit

class RegistUserInfoModel: BaseModel,Codable {
  var mobile = ""
  var email = ""
  var IcNum = ""
  var password = ""
  var firstName = ""
  var lastName = ""
  var gender = ""
  var dataOfBirth = ""
  var isCustomer = ""
  var referralCode = ""
  var postalCode = ""
  var blockNum = ""
  var streetName = ""
  var unitNum = ""
  var city = ""
  var country_id = ""
  
  var is_new_register = false
  
  var present_reward_discount_id = ""
  var present_invite_cash_voucher = ""
  var present_cash_voucher = ""
  var is_display_on_all_booking = ""
}
