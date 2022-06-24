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
  var outlet:(id:String,name:String)?
  convenience init(isFromScanQRCode:Bool = false,outlet:(id:String,name:String)?) {
    self.init()
    self.isFromScanQRCode = isFromScanQRCode
    self.outlet = outlet
  }
  var content = EnterAccountContainer.loadViewFromNib()
    override func viewDidLoad() {
        super.viewDidLoad()

      IQKeyboardManager.shared.enableAutoToolbar = false
      
      self.view.addSubview(content)
      content.isFromScanQRCode = isFromScanQRCode
      content.outlet = outlet
      content.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    }
    

}
