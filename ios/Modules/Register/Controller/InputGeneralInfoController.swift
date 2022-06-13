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
  var scrollView = UIScrollView()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = R.color.theamBlue()
    
    self.view.addSubview(scrollView)
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    scrollView.contentSize = CGSize(width: kScreenWidth, height: 740)
  
    scrollView.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 740)
    
    titleView.size = CGSize(width: 200, height: 4)
    self.navigation.item.titleView = titleView
    titleView.forward(to: 2)
    
    IQKeyboardManager.shared.enableAutoToolbar = false
  }
  
  
  
    
}
