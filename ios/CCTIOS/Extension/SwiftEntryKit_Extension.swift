//
//  SwiftEntryKit_Extension.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/7/11.
//

import Foundation
import SwiftEntryKit
import UIKit

extension UIColor {
  static let dimmedLightBackground = UIColor(white: 100.0/255.0, alpha: 0.3)
  static let dimmedDarkBackground = UIColor(white: 50.0/255.0, alpha: 0.3)
  static let dimmedDarkestBackground = UIColor(white: 0, alpha: 0.5)
  static let musicBackgroundDark = UIColor(red: 36, green: 39, blue: 42)
}

extension SwiftEntryKit {
  static var displayMode = EKAttributes.DisplayMode.inferred
  static var bottomAlertAttributes: EKAttributes {
    var attributes = EKAttributes.bottomFloat
    attributes.displayDuration = .infinity
    attributes.entryBackground = .color(color: .standardBackground)
    attributes.screenBackground = .color(color: EKColor.init(UIColor.black.withAlphaComponent(0.8)))
    attributes.screenInteraction = .dismiss
    attributes.entryInteraction = .absorbTouches
    attributes.scroll = .edgeCrossingDisabled(swipeable: true)
    attributes.entranceAnimation = .init(
      translate: .init(
        duration: 0.5,
        spring: .init(damping: 1, initialVelocity: 0)
      )
    )
    attributes.exitAnimation = .init(
      translate: .init(duration: 0.2)
    )
    attributes.popBehavior = .animated(
      animation: .init(
        translate: .init(duration: 0.2)
      )
    )
    attributes.positionConstraints.verticalOffset = 0
   
    
    attributes.statusBar = .dark
    return attributes
  }
  
  static func displayView(asSheet view:UIView, size:CGSize) {
    var attributes: EKAttributes = bottomAlertAttributes
    attributes.displayMode = displayMode
    attributes.positionConstraints.size = .init(
      width: .constant(value: size.width),
      height: .constant(value: size.height)
    )
    view.size = size
    SwiftEntryKit.display(entry: view, using: attributes)
  }
}




extension CGRect {
  var minEdge: CGFloat {
    return min(width, height)
  }
}
