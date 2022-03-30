//
//  APIError.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/31.
//

import Foundation
let DecodeErrorCode = -7777
let NetworkErrorCode = -8888
let ServiceErrorCode = -9999

enum APIError:Error {
  case serviceError(DataParseErrorType)
  case networkError(Error)
  case requestError(code:Int,message:String)
  
  static func errorCodeHandler(_ code:Int,_ message:String,_ isNeedToast:Bool = true) {
    
    print("code:\(code) message:\(message)")
  }
  
  
}

extension APIError {
  func errorInfo() -> (code:Int,message:String) {
    switch self {
    case .networkError(let error):
      let err = error as NSError
      return (NetworkErrorCode,err.localizedDescription)
    case .serviceError(let parseType):
      return (ServiceErrorCode,parseType.description)
    case .requestError(let code, let message):
      return (code,message)
    }
  }
  var emptyDatatype:EmptyDataType {
    switch self {
    case .networkError(let error):
      let err = error as NSError
      return .Network(code: err.code, message: err.description)
    case .serviceError(let type):
      return .Service(code: -1, message: type.description)
    case .requestError(let code, let message):
      return .Service(code:code,message:message)
    }
  }
}


extension Error {
  var asAPIError:APIError {
    return (self as! APIError)
  }
  var asPKError:PKError {
    return (self as! PKError)
  }
}
