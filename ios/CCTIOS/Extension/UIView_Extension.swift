//
//  UIView_Shadow.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import Foundation
// MARK:- shadow
extension UIView {
  /// 添加阴影
  ///
  /// - Parameters:
  ///   - cornerRadius: 圆角大小
  ///   - color: 阴影颜色
  ///   - offset: 阴影偏移量
  ///   - radius: 阴影扩散范围
  ///   - opacity: 阴影的透明度
  func shadow(cornerRadius: CGFloat, color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
    self.layer.cornerRadius = cornerRadius
    self.layer.masksToBounds = true
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOffset = offset
    self.layer.shadowRadius = radius
    self.layer.shadowOpacity = opacity
    self.layer.masksToBounds = false
    self.layer.rasterizationScale = UIScreen.main.scale
    self.layer.shouldRasterize = true
  }
  
  /// 添加部分圆角
  func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
    let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
    let maskLayer = CAShapeLayer()
    maskLayer.frame = self.bounds
    maskLayer.path = maskPath.cgPath
    self.layer.mask = maskLayer
  }
  
  func addLightShadow(by radius:CGFloat) {
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.12)
    self.shadow(cornerRadius: radius, color: light, offset: CGSize(width: 0, height: 1), radius: 5, opacity: 1)
  }
}


// MARK:-Nibloadable
extension UIView {
    static var NibName: String {
        return String(self.className)
    }
    static func loadViewFromNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.last as! Self
    }
}


extension UILabel  {
  // MARK: 3.4、设置特定文字的字体颜色
  /// 设置特定文字的字体颜色
  /// - Parameters:
  ///   - text: 特定文字
  ///   - color: 字体颜色
  func setSpecificTextColor(_ text: String, color: UIColor) {
      let attributedString = self.attributedText?.setSpecificTextColor(text, color: color)
      self.attributedText = attributedString
  }
  
}
