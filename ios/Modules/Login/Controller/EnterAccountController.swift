//
//  EnterAccountController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/28.
//

import UIKit
import IQKeyboardManagerSwift
class EnterAccountController: BaseViewController {
  var isFromScanQRCode = false
  convenience init(isFromScanQRCode:Bool = false) {
    self.init()
    self.isFromScanQRCode = isFromScanQRCode
  }
  var content = EnterAccountContainer.loadViewFromNib()
    override func viewDidLoad() {
        super.viewDidLoad()

      IQKeyboardManager.shared.enableAutoToolbar = false
      
      self.view.addSubview(content)
      content.isFromScanQRCode = isFromScanQRCode
      content.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    }
    

}
