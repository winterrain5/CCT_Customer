//
//  InputGeneralInfoController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/8.
//

import UIKit
import IQKeyboardManagerSwift
class InputGeneralInfoController: BaseViewController {

  var contentView = InputGeneralInfoView.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    IQKeyboardManager.shared.enableAutoToolbar = false
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
  }
  
    
}
