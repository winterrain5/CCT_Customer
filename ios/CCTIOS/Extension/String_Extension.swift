//
//  String_Extension.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import Foundation
import CommonCrypto
extension String {
  var asURL:URL? {
    return URL(string: APIHost().URL_API_IMAGE + (self.removingPrefix(".").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: " ", with: "%20") ?? ""))
  }
  
  /// number of digits 保留位数
  func formatMoney(nd:Int = 2) -> String {
    return String(format: "%.\(nd)f", (self.double() ?? 0) * 1000 / 1000)
  }
  
  var dolar:String {
    "$" + self.formatMoney()
  }
  
  func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
    return boundingBox.height
    
  }
  func widthWithConstrainedWidth(height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
    return boundingBox.width
    
  }
  
  var md5: String {
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    CC_MD5(str!, strLen, result)
    
    let hash = NSMutableString()
    
    for i in 0..<digestLen {
      hash.appendFormat("%02x", result[i])
    }
    
    result.deallocate()
    return hash as String
  }
  
  func isHasLowercaseCharacter() -> Bool {
    let rule = "(?s)[^a-z]*[a-z].*"
    let regex = NSPredicate(format: "SELF MATCHES %@",rule)
    if regex.evaluate(with: self) {
      return true
    }else
    {
      return false
    }
  }
  func isHasUppercaseCharacter() -> Bool {
    let rule = "(?s)[^A-Z]*[A-Z].*"
    let regex = NSPredicate(format: "SELF MATCHES %@",rule)
    if regex.evaluate(with: self) {
      return true
    }else
    {
      return false
    }
  }
  func isHasSpecialSymbol() -> Bool {
    let rule = "#@!~%^&*"
    var result = false
    for c in self.charactersArray {
      if rule.charactersArray.contains(c) {
        result = true
        break
      }
    }
    return result
  }
  
  func isPasswordRuler() -> Bool {
    let passwordRule = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{6,}$"
    let regexPassword = NSPredicate(format: "SELF MATCHES %@",passwordRule)
    if regexPassword.evaluate(with: self) == true {
      return true
    }else
    {
      return false
    }
  }
  
  func isNRICRuler() -> Bool {
    let rule = "^[STFG]\\d{7}[A-Z]$"
    let regex = NSPredicate(format: "SELF MATCHES %@",rule)
    if regex.evaluate(with: self) == true {
      return true
    }else
    {
      return false
    }
  }
 
  func replaceHTMLLabel() -> String{
    var html = self
    html = html.replacingOccurrences(of: "&", with: "&amp;")
    html = html.replacingOccurrences(of: "<", with: "&lt;")
    html = html.replacingOccurrences(of: ">", with: "&gt;")
    return html
  }
  
}
