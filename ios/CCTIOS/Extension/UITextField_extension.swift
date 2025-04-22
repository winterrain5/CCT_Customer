//
//  UITextField_extension.swift
//  CCTIOS
//
//  Created by Derrick on 2025/4/21.
//

import Foundation
import UIKit
extension UITextField {
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}
