//
//  InputResideController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/8.
//

import UIKit
import IQKeyboardManagerSwift
class InputResideController: BaseViewController {

  var contentView = InputResideView.loadViewFromNib()
  var titleView = RegistStepView()

  override func viewDidLoad() {
    super.viewDidLoad()
    IQKeyboardManager.shared.enableAutoToolbar = true
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    
    titleView.size = CGSize(width: 200, height: 4)
    self.navigation.item.titleView = titleView
    titleView.forward(to: 3)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    IQKeyboardManager.shared.enableAutoToolbar = false
  }
  

}
