//
//  SymptomCheckLetGoController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckLetGoController: BaseViewController {

  private var container = SymptomCheckLetGoContainer.loadViewFromNib()
  private var result:[Int:[SymptomCheckStepModel]] = [:]
  init(result:[Int:[SymptomCheckStepModel]] = [:]) {
    super.init(nibName: nil, bundle: nil)
    self.result = result
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.bar.alpha = 0
    self.interactivePopGestureRecognizerEnable = false
    self.barAppearance(tintColor: .white,barBackgroundColor: .white, image: R.image.return_left(),backButtonTitle: "Exit")
    self.view.addSubview(container)
    container.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    container.goHandler = { [weak self] in
      guard let `self` = self else { return }
      let vc = SymptomCheckDetailController(result: self.result)
      self.navigationController?.pushViewController(vc)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.updateStatusBarStyle(true)
  }
  
  override func backAction() {
    AlertView.show(title: "Are you sure you want to Exit?", rightHandler:  {
      self.navigationController?.popToRootViewController(animated: true)
    })
  }

}
