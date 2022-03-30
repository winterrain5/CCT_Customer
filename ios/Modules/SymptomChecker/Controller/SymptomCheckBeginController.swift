//
//  SymptomCheckBeginController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckBeginController: BaseViewController {
  private var container = SymptomCheckBeginContainer.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    self.interactivePopGestureRecognizerEnable = false
    self.barAppearance(tintColor: .black,barBackgroundColor: .white, image: R.image.return_left_black(),backButtonTitle: "Exit")
    self.view.addSubview(container)
    container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.updateStatusBarStyle(false)
  }
  
  override func backAction() {
    AlertView.show(title: "Are you sure you want to Exit?", rightHandler:  {
      self.navigationController?.popToRootViewController(animated: true)
    })
  }

}
