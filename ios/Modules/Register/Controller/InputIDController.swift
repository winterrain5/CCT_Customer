//
//  InputIDController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/7.
//

import UIKit
import IQKeyboardManagerSwift

class InputIDController: BaseViewController {
  var contentView = InputIDContainer.loadViewFromNib()
  var scrollView = UIScrollView()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = R.color.theamBlue()
    
    self.view.addSubview(scrollView)
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    let contentH = kScreenHeight - kNavBarHeight < 685 ? 685 : kScreenHeight - kNavBarHeight
    scrollView.contentSize = CGSize(width: kScreenWidth, height: contentH)
    
    scrollView.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: contentH)

    
  }
  
  
  
}
