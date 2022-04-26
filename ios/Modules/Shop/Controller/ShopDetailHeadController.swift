//
//  ShopDetailHeadController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/13.
//

import UIKit

class ShopDetailHeadController: BaseViewController {
  
  let contentView = ShopDetailHeadContainer.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 441)
  }
  
  
  
}
