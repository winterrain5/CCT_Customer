//
//  NSObject_Extension.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
