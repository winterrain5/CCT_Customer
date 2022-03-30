//
//  ReferFriendController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/16.
//

import UIKit

class ReferFriendController: BaseViewController {
  var container = ReferFriendContainer.loadViewFromNib()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.bar.backgroundColor = R.color.theamBlue()
    self.view.addSubview(container)
    container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight)
  }
}
