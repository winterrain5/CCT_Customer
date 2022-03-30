//
//  SOAPParams.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/31.
//

import UIKit

enum SOAPParamsType {
  case map(Int = 0)
  case string
  
  var result:String {
    switch self {
    case .map(let i):
      return "i:type=\"n\(i):Map\" xmlns:n\(i)=\"http://xml.apache.org/xml-soap\""
    case .string:
      return "i:type=\"d:string\""
    }
  }
}

class SOAPParams {
 
  /// 入参
  var result:String = ""
  var action:String = ""
  var path:String = ""
  var isNeedToast:Bool = true
  /// 网络请求构造类
  /// - Parameters:
  ///   - action:  服务器接口对应的控制器
  ///   - path: 接口名称
  init(action:Action,path:API,isNeedToast:Bool = true) {
    self.action = action.rawValue
    self.path = path.rawValue
    self.isNeedToast = isNeedToast
  }
  
  init() {}
  
  func set(key:String,value:Any,type:SOAPParamsType = .string) {
    result += "<\(key) \(type.result)>\(value)</\(key)>"
  }

}

class SOAPDictionary {
  var result:String = ""
  func set(key:String,value:Any,type:SOAPParamsType = .string) {
    result += "<item><key \(type.result)>\(key)</key><value \(type.result)>\(value)</value></item>"
  }
  func set(key:String,value:Any,keyType:SOAPParamsType = .string, valueType:SOAPParamsType = .string) {
    result += "<item><key \(keyType.result)>\(key)</key> <value \(valueType.result)>\(value)</value></item>"
  }
}
