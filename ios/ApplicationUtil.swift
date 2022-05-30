//
//  ApplicationUtil.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/10.
//

import UIKit
import SideMenuSwift
@objcMembers class ApplicationUtil:NSObject {
  static func configRootViewController() {
    
    SideMenuController.preferences.basic.menuWidth = kScreenWidth * 0.75
    SideMenuController.preferences.basic.statusBarBehavior = .hideOnMenu
    SideMenuController.preferences.basic.position = .above
    SideMenuController.preferences.basic.direction = .left
    SideMenuController.preferences.basic.enablePanGesture = true
    SideMenuController.preferences.basic.supportedOrientations = .portrait
    SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
    let window = (UIApplication.shared.delegate as! AppDelegate).window
    if (CheckUserLogin.isLogined) {
      let tab = BaseTabBarController()
      window?.rootViewController = SideMenuController(contentViewController: tab, menuViewController: MenuViewController())
    }else {
      let rootViewController = LoginViewController()
      let nav = BaseNavigationController(rootViewController: rootViewController)
      window?.rootViewController = nav
    }
    
  }
}
