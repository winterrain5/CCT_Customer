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
    return T.deserialize(from: jsonString)
  }
  
  static func decodeArrayByHandJSON<T:HandyJSON>(_ type:T.Type,from data:Data) -> [T]? {
    let jsonArray = JSON.init(from: data)?.arrayObject
    return Array<T>.deserialize(from: jsonArray) as? [T]
  }

}
