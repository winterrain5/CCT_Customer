//
//  InputIDController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/7.
//

import UIKit

class InputIDController: BaseViewController {
  var contentView = InputIDContainer.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
  }
  
  
  
}
