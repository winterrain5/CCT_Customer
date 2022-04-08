//
//  WalletInviteUserModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/9.
//

import UIKit

class UserContactModel {
  var id:String = ""
  var name:String
  var phone:String
  var isAdd:Bool = false
  init(name:String,phone:String){
    self.name = name
    self.phone = phone
  }
}
