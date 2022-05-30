//
//  UIFont_Extension.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import Foundation
import UIKit
enum AvenirNextName:String {
  case AvenirNextRegular = "AvenirNext-Regular"
  case AvenirNextItalic = "AvenirNext-Italic"
  case AvenirNextUltraLight = "AvenirNext-UltraLight"
  case AvenirNextUltraLightItalic = "AvenirNext-UltraLightItalic"
  case AvenirNextMedium = "AvenirNext-Medium"
  case AvenirNextMediumItalic = "AvenirNext-MediumItalic"
  case AvenirNextDemiBold = "AvenirNext-DemiBold"
  case AvenirNextDemiBoldItalic = "AvenirNext-DemiBoldItalic"
  case AvenirNextBold = "AvenirNext-Bold"
  case AvenirNextBoldItalic = "AvenirNext-BoldItalic"
  case AvenirNextHeavy = "AvenirNext-Heavy"
  case AvenirNextHeavyItalic = "AvenirNext-HeavyItalic"
  case AvenirBook = "Avenir-Book"
  case AvenirRoman = "Avenir-Roman"
  case AvenirBookOblique = "Avenir-BookOblique"
  case AvenirOblique = "Avenir-Oblique"
  case AvenirLight = "Avenir-Light"
  case AvenirLightOblique = "Avenir-LightOblique"
  case AvenirMedium = "Avenir-Medium"
  case AvenirMediumOblique = "Avenir-MediumOblique"
  case AvenirHeavy = "Avenir-Heavy"
  case AvenirHeavyOblique = "Avenir-HeavyOblique"
  case AvenirBlack = "Avenir-Black"
  case AvenirBlackOblique = "Avenir-BlackOblique"
}

/*
 "*/

extension UIFont {
  convenience init(name:AvenirNextName,size:CGFloat)  {
    self.init(name: name.rawValue, size: size)!
  }
}
