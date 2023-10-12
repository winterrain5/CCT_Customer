//
//  PKError.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/11.
//

import Foundation
enum PKError:Error {
    case some(_ message:String)
    
    var message:String {
        switch self {
        case .some(let message):
            return message
        }
    }
}
