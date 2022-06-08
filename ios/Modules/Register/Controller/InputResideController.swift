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
  override func viewDidLoad() {
    super.viewDidLoad()
    IQKeyboardManager.shared.enableAutoToolbar = true
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    IQKeyboardManager.shared.enableAutoToolbar = false
  }
  

}
