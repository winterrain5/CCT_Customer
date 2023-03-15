//
//  ApplicationUtil.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/10.
//

import UIKit
import SideMenuSwift
import IQKeyboardManagerSwift
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
    
    if Defaults.shared.get(for: .isFirstInstallApp) != nil {
      if (CheckUserLogin.isLogined) {
        Defaults.shared.set(false, for: .isFirstLogin)
        let tab = BaseTabBarController()
        window?.rootViewController = SideMenuController(contentViewController: tab, menuViewController: MenuViewController())
      }else {
        let rootViewController = LoginViewController()
        let nav = BaseNavigationController(rootViewController: rootViewController)
        window?.rootViewController = nav
      }
    }else {
      let vc = OnBoardViewController()
      window?.rootViewController = vc
    }
   
    
    configKeyBoard()
  }
  
  static func setRootViewController() {
    
    Defaults.shared.set(false, for: .isFirstLogin)
    DispatchQueue.main.async {
      let tab = BaseTabBarController()
      let window = (UIApplication.shared.delegate as! AppDelegate).window
      window?.rootViewController = SideMenuController(contentViewController: tab, menuViewController: MenuViewController())
    }
   
  }
  
  static func configKeyBoard() {
    let manager = IQKeyboardManager.shared
    manager.enable = true
    manager.shouldResignOnTouchOutside = true
    manager.shouldShowToolbarPlaceholder = true
    manager.enableAutoToolbar = false
  }
  
  static func navgateToMessageController() {
    let window = (UIApplication.shared.delegate as! AppDelegate).window
    guard let tab = (window?.rootViewController as? SideMenuController)?.contentViewController as? BaseTabBarController else {
      return
    }
    tab.selectedIndex = 2
  }
  
  static func setTabBarItemBadgeValue(value:Int) {
    let window = (UIApplication.shared.delegate as! AppDelegate).window
    guard let tab = (window?.rootViewController as? SideMenuController)?.contentViewController as? BaseTabBarController else {
      return
    }
    let vc = tab.viewControllers?[2]
    if value == 0 {
      MobPush.clearBadge()
      UIApplication.shared.applicationIconBadgeNumber = 0
      vc?.tabBarItem.badgeValue = nil
      return
    }
    UIApplication.shared.applicationIconBadgeNumber = value
    
    MobPush.setBadge(value)
    vc?.tabBarItem.badgeValue = "\(value)"
  }
  
  static func alertMessage(_ message:String) {
    AlertView.show(message: message)
  }
  
}


