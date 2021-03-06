//
//  Decoder.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import Foundation
import HandyJSON
class DecodeManager {
  
  static func decodeByCodable<T:Codable>(_ type:T.Type,from data:Data) -> T? {
    let decode = JSONDecoder()
    let retuslt = try? decode.decode(type, from: data)
    return retuslt
  }
  
  static func decodeObjectByHandJSON<T:HandyJSON>(_ type:T.Type,from data:Data) -> T? {
    let jsonString = JSON.init(from: data)?.rawString()
    if jsonString == nil {
      let jsonDict = JSON.init(from: data)?.rawValue as? NSDictionary
      return T.deserialize(from: jsonDict)
    }
    return T.deserialize(from: jsonString)
  }
  
  static func decodeArrayByHandJSON<T:HandyJSON>(_ type:T.Type,from data:Data) -> [T]? {
    var jsonArray = JSON.init(from: data)?.arrayObject
    if jsonArray == nil {
      jsonArray = JSON.init(from: data)?["data"].arrayObject
    }
    return Array<T>.deserialize(from: jsonArray) as? [T]
  }

}
