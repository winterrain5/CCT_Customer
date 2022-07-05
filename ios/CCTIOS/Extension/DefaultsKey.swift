//
//  DefaultsKey.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/31.
//

import Foundation

extension DefaultsKey {
  static let clientId = Key<String>("clientId")
  static let loginPwd = Key<String>("loginPwd")
  static let companyId = Key<String>("companyId")
  static let sendEmail = Key<String>("sendEmail")
  static let recieveEmail = Key<String>("recieveEmail")
  
  static let userModel = Key<UserModel>("UserModel")
  
  static let registModel = Key<RegistUserInfoModel>("RegistUserInfoModel")
  
  static let payMethodLine = Key<MethodLines>("PayMethodLine")
  static let payMethodId = Key<String>("PayMethodId")
  
  static let blogFilterKey = Key<String>("blogFilterKey")
  
  static let isReview = Key<Bool>("isReview")
  
  static let isFirstLogin = Key<Bool>("isFirstLogin")
  static let isFirstInstallApp = Key<Bool>("isFirstInstallApp")
  static let isLoginByScanQRCode = Key<Bool>("isLoginByScanQRCode")
  
}
