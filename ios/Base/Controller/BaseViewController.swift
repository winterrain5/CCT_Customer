//
//  BaseViewController.swift
//  OneOnline
//
//  Created by Derrick on 2020/2/28.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit
import EachNavigationBar

class BaseViewController: UIViewController {
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  private lazy var leftButton = UIButton()
  
  var leftButtonDidClick:(()->())?
  var interactivePopGestureRecognizerEnable:Bool = true{
    didSet {
      navigationController?.interactivePopGestureRecognizer?.isEnabled = interactivePopGestureRecognizerEnable
    }
  }

  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.white
    extendedLayoutIncludesOpaqueBars = true
    interactivePopGestureRecognizerEnable = true
    
    self.barAppearance()
    self.updateStatusBarStyle()
    
   
  }
  
  func addLeftBarButtonItem(_ image:UIImage? = UIImage(named: "return_left")) {
    leftButton.setImage(image, for: .normal)
    leftButton.frame = CGRect(x: 0, y: 0, width: 33, height: 40)
    leftButton.contentHorizontalAlignment = .left
    leftButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
  }
  
  func updateStatusBarStyle(_ isLight: Bool = true) {
    var statusBarStyle: UIStatusBarStyle
    if !isLight, #available(iOS 13.0, *) {
      statusBarStyle = .darkContent
    } else {
      statusBarStyle = isLight ? .lightContent : .default
    }
    UIApplication.shared.setStatusBarStyle(statusBarStyle, animated: true)
  }
  
  
  
  @objc func backAction() {
    if let click = leftButtonDidClick {
      click()
    }else {
      if let nav = self.navigationController {
        nav.popViewController(animated: true)
      }else {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.view.endEditing(true)
  }
  
  
  /// 设置NavBar外观
  /// - Parameters:
  ///   - tintColor: 文字颜色
  ///   - barBackgroundColor: 背景色
  ///   - image: 返回按钮图片
  ///   - backButtonTitle: 返回按钮文字
  func barAppearance(tintColor:UIColor = .white,barBackgroundColor:UIColor = R.color.theamBlue()!,image:UIImage? = UIImage(named: "return_left"),backButtonTitle:String? = nil) {
    addLeftBarButtonItem(image)
    self.leftButton.titleForNormal = " \(backButtonTitle ?? "")"
    self.leftButton.titleColorForNormal = tintColor
    self.leftButton.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:16)
    self.navigation.bar.tintColor = tintColor
    self.navigation.bar.barTintColor = barBackgroundColor
  }
  
  deinit {
    Toast.dismiss()
    print("\(self.className) 销毁了")
  }
}


