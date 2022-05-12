//
//  File.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/30.
//

import Foundation

extension Notification.Name {
  static let openNativeVc = Notification.Name(rawValue: "openNativeVc")
  static let goBackNativeVc = Notification.Name(rawValue: "goBackNativeVc")
  static let goBackToRootNativeVc = Notification.Name(rawValue: "goBackToRootNativeVc")
  static let openWebVc = Notification.Name(rawValue: "openWebVc")
  static let payment = Notification.Name(rawValue: "payment")
  static let nativeNotification = Notification.Name(rawValue: "native_onNotification")
  static let saveClientId = Notification.Name(rawValue: "SaveClientId")
  static let saveUserId = Notification.Name(rawValue: "SaveUserId")
  static let saveCompanyId = Notification.Name(rawValue: "SaveCompanyId")
  static let saveLoginPwd = Notification.Name(rawValue: "SaveLoginPwd")
 
  static let setBlogStatus = Notification.Name(rawValue: "setBlogStatus")
  static let shareBlog = Notification.Name(rawValue: "shareBlog")
  static let removeLocalData = Notification.Name(rawValue: "removeLocalData")
  static let reviewOrderComplete = Notification.Name(rawValue: "reviewOrderComplete")
  
  static let menuDidOpenVc = Notification.Name(rawValue: "menuDidOpenVc")
  static let menuInfoShouldChange = Notification.Name(rawValue: "menuInfoShouldChange")
}
