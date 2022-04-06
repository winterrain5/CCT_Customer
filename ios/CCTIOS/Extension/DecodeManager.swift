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
  
  static func decodeByHandJSON<T:HandyJSON>(_ type:T.Type,from data:Data) -> T? {
    let jsonString = JSON.init(from: data)?.rawString()
    return type.deserialize(from: jsonString)
  }

}
