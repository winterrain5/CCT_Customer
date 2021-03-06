//
//  DefaultsKey.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/31.
//

import Foundation

extension DefaultsKey {
  static let userId = Key<String>("userId")
  static let clientId = Key<String>("clientId")
  static let loginPwd = Key<String>("loginPwd")
  static let companyId = Key<String>("companyId")
  
  static let userModel = Key<UserModel>("UserModel")
  
  static let payMethodLine = Key<MethodLines>("PayMethodLine")
  static let payMethodId = Key<String>("PayMethodId")
  
  static let blogFilterKey = Key<String>("blogFilterKey")
}
