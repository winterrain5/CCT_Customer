//
//  BaseTabBarController.swift
//  OneOnline
//
//  Created by Derrick on 2020/2/28.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit

enum TabConstants {
  
  static let homeTitle = "Home"
  static let homeImage = R.image.tab_home_normal()
  static let homeSelectedImage = R.image.tab_home_select()
  
  static let bookingTitle = "Booking"
  static let bookingImage = R.image.tab_calendar_normal()
  static let bookingSelectedImage = R.image.tab_calendar_select()
  
  static let notiTitle = "Notification"
  static let notiImage = R.image.tab_notification_normal()
  static let notiSelectedImage = R.image.tab_notification_select()
  
  static let profileTitle = "Profile"
  static let profileImage = R.image.tab_profile_normal()
  static let profileSelectedImage = R.image.tab_profile_select()
  
  static let selectColor = R.color.theamColor()
  static let unSelectColor = R.color.gray82()
}

class BaseTabBarController: UITabBarController {
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setupChildController()
  }
  
  internal required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func setupChildController() {
    let home = BaseNavigationController(rootViewController: HomeViewController())
    let booking = BaseNavigationController(rootViewController: BookingViewController())
    let noti = BaseNavigationController(rootViewController: NotificationViewController())
    let profile = BaseNavigationController(rootViewController: ProfileViewController())
    
    home.tabBarItem = UITabBarItem.init(
      title: TabConstants.homeTitle,
      image: TabConstants.homeImage,
      selectedImage: TabConstants.homeSelectedImage)
    booking.tabBarItem = UITabBarItem.init(
      title: TabConstants.bookingTitle,
      image: TabConstants.bookingImage,
      selectedImage: TabConstants.bookingSelectedImage)
    
    noti.tabBarItem = UITabBarItem.init(
      title: TabConstants.notiTitle,
      image: TabConstants.notiImage,
      selectedImage: TabConstants.notiSelectedImage)
    
    profile.tabBarItem = UITabBarItem.init(
      title: TabConstants.profileTitle,
      image: TabConstants.profileImage,
      selectedImage: TabConstants.profileSelectedImage)
    
    self.viewControllers = [home,booking,noti,profile]
    configAppearance()
  }
  
  
  func configAppearance() {
    
    let normalFont: UIFont = UIFont(.AvenirNextRegular,10)
    let selectFont: UIFont = UIFont(.AvenirNextDemiBold,13)
    
    
    let selectAttributes:[NSAttributedString.Key:Any] =  [NSAttributedString.Key.foregroundColor: TabConstants.selectColor as Any,NSAttributedString.Key.font: selectFont]
    
    let unSelectAttributes:[NSAttributedString.Key:Any] =  [NSAttributedString.Key.foregroundColor: TabConstants.unSelectColor as Any,NSAttributedString.Key.font: normalFont]
    
    if #available(iOS 13, *) {
      let appearance = UITabBarAppearance()
      let normal = appearance.stackedLayoutAppearance.normal
      normal.titleTextAttributes = unSelectAttributes
      let select = appearance.stackedLayoutAppearance.selected
      select.titleTextAttributes = selectAttributes
      appearance.backgroundColor = .white
      appearance.backgroundImage = UIImage()
      appearance.shadowImage = UIImage()
      appearance.shadowColor = .clear
      self.tabBar.standardAppearance = appearance
    } else {
      UITabBarItem.appearance().setTitleTextAttributes(unSelectAttributes, for: .normal)
      UITabBarItem.appearance().setTitleTextAttributes(selectAttributes, for: .selected)
      self.tabBar.shadowImage = UIImage()
      self.tabBar.backgroundImage = UIImage()
      self.tabBar.backgroundColor = .white
    }
    
    self.tabBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.09).cgColor
    self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
    self.tabBar.layer.shadowOpacity = 1
    self.tabBar.layer.shadowRadius = 16
    
  }
  
  
  
}

