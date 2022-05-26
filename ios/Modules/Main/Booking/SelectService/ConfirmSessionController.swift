//
//  ConfirmSessionController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/24.
//

import UIKit

class ConfirmSessionController: BaseViewController {
  
  var contentView = ConfirmSessionContainer.loadViewFromNib()
  var params:ConfirmSessionModel!
  convenience init(params:ConfirmSessionModel) {
    self.init()
    self.params = params
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.backgroundColor = R.color.theamBlue()
    
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    contentView.model = params
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  
  
}
