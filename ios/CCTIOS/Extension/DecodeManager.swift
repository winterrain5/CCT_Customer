//
//  Decoder.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import Foundation

class DecodeManager {
  
  static func decode<T:Codable>(_ type:T.Type,from data:Data) -> T? {
    let decode = JSONDecoder()
    let retuslt = try? decode.decode(type, from: data)
    return retuslt
  }

}
