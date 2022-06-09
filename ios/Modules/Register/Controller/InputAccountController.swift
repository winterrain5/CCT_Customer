//
//  InputAccountController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/7.
//

import UIKit
import IQKeyboardManagerSwift

class InputAccountController: BaseViewController {

  var contentView = InputAccountContainer.loadViewFromNib()
  var titleView = RegistStepView()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    
    titleView.size = CGSize(width: 200, height: 4)
    self.navigation.item.titleView = titleView
    titleView.forward(to: 1)
    
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  
  
}
