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
  var titleView = RegistStepView()

  override func viewDidLoad() {
    super.viewDidLoad()
    IQKeyboardManager.shared.enableAutoToolbar = false
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    
    titleView.size = CGSize(width: 200, height: 4)
    self.navigation.item.titleView = titleView
    titleView.forward(to: 2)
  }
  
    
}
