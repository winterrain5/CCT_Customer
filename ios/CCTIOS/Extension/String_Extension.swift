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
  
  func formatMoney() -> String {
    return String(format: "%.2f", (self.double() ?? 0) * 1000 / 1000)
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
  
  
}
