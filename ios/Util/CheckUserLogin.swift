//
//  CheckUserLogin.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/29.
//

import UIKit


@objcMembers class CheckUserLogin: NSObject {
  static var isLogined:Bool {
    if let _ = Defaults.shared.get(for: .userId) {
      return true
    }else {
      return false
    }
  }
}
