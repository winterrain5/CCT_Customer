//
//  InputPhoneController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/10.
//

import UIKit

class InputPhoneController: BaseViewController {

  var contentView = InputPhoneView.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    Defaults.shared.removeAll()
    
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)

    
  }
  

}
