//
//  CallUtil.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/25.
//

import UIKit

@objcMembers
class CallUtil: NSObject {
  
  static func callWhatsapp(_ number:String) {
      AlertView.show(title: "Do you want to chat with \(number)?", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Sure", messageAlignment: .center, leftHandler: nil, rightHandler: {
        let phone = "https://api.whatsapp.com/send?phone=65\(number)"
        self.call(with: phone)
      }, dismissHandler: nil)
  }
  
  static func callPhone(_ number:String) {
    AlertView.show(title:  "Do you want to call \(number)?", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Sure", messageAlignment: .center, leftHandler: nil, rightHandler: {
      let phone = "tel://\(number)"
      self.call(with: phone)
    }, dismissHandler: nil)
   
  }

  static func call(with phone:String) {
    guard let url =  URL(string: phone) else {
      Toast.showError(withStatus: "wrong number")
      return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}
