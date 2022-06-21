//
//  UIView+Badge.swift
//  VictorOnlineParent
//
//  Created by Derrick on 2020/7/7.
//  Copyright © 2020 Victor. All rights reserved.
//

import Foundation

private var view_badgeKey : Void?
private var view_badgeBGColorKey : Void?
private var view_badgeTextColorKey : Void?
private var view_badgeFontKey : Void?
private var view_badgePaddingKey : Void?
private var view_badgeMinSizeKey : Void?
private var view_badgeOriginXKey : Void?
private var view_badgeOriginYKey : Void?
private var view_shouldHideBadgeAtZeroKey : Void?
private var view_shouldAnimateBadgeKey : Void?
private var view_badgeValueKey : Void?
private var view_badgeTypeKey: Void?
extension UIView {
    
    enum BadgeType {
        case Dot
        case Text
    }
    
    // MARK: - 角标
    fileprivate var badgeLabel: UILabel? {
        get {
            return  objc_getAssociatedObject(self, &view_badgeKey) as? UILabel
        }
        set {
            objc_setAssociatedObject(self, &view_badgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
    
    // MARK: - 角标
    /**
     * 角标值
     */
    var badgeValue : String?  {
        get{
            return objc_getAssociatedObject(self, &view_badgeValueKey) as? String
        }
        
        set (badgeValue){
            objc_setAssociatedObject(self, &view_badgeValueKey, badgeValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            switch badgeType {
            case .Dot:
                if (badgeValue?.isEmpty)!   || (badgeValue == "") || ((badgeValue == "0") && shouldHideBadgeAtZero) {
                    removeBadge()
                } else if (self.badgeLabel == nil ) {
                    self.badgeLabel  = UILabel(frame: CGRect(x: self.badgeOriginX , y: self.badgeOriginY, width: self.badgeMinSize, height: self.badgeMinSize))
                    self.badgeLabel?.backgroundColor = self.badgeBGColor
                    addSubview(self.badgeLabel!)
                    updateBadgeValue()
                } else {
                    updateBadgeValue()
                }
            case .Text, .none:
                if (badgeValue?.isEmpty)!   || (badgeValue == "") || ((badgeValue == "0") && shouldHideBadgeAtZero) {
                    removeBadge()
                } else if (self.badgeLabel == nil ) {
                    self.badgeLabel  = UILabel(frame: CGRect(x: self.badgeOriginX , y: self.badgeOriginY, width: self.badgeMinSize, height: self.badgeMinSize))
                    self.badgeLabel?.textColor = self.badgeTextColor
                    self.badgeLabel?.backgroundColor = self.badgeBGColor
                    self.badgeLabel?.font = self.badgeFont
                    addSubview(self.badgeLabel!)
                    updateBadgeValue()
                } else {
                    updateBadgeValue()
                }
                
            }
            
        }
        
    }
    
    var badgeType: BadgeType? {
        get {
            return objc_getAssociatedObject(self, &view_badgeTypeKey) as? BadgeType ?? .Dot
        }
        set (badgeType) {
            objc_setAssociatedObject(self, &view_badgeTypeKey, badgeType, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /**
     * Badge background color
     */
    var badgeBGColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &view_badgeBGColorKey) as? UIColor ?? .red
        }
        set {
            objc_setAssociatedObject(self, &view_badgeBGColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { refreshBadge() }
        }
    }
    
    /**
     * Badge text color
     */
    var badgeTextColor: UIColor? {
        get{
            return objc_getAssociatedObject(self, &view_badgeTextColorKey) as? UIColor ?? .white
        }
        set{
            objc_setAssociatedObject(self, &view_badgeTextColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) {  refreshBadge() }
        }
    }
    
    
    /**
     * Badge font
     */
    var badgeFont: UIFont? {
        get {
            return objc_getAssociatedObject(self, &view_badgeFontKey) as? UIFont ?? UIFont.systemFont(ofSize: 12)
        }
        set{
            objc_setAssociatedObject(self, &view_badgeFontKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { refreshBadge() }
        }
    }
    
    /**
     *  Padding value for the badge
     */
    var badgePadding: CGFloat {
        get{
            return  objc_getAssociatedObject(self, &view_badgePaddingKey) as? CGFloat ?? 0
        }
        set{
            objc_setAssociatedObject(self, &view_badgePaddingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { updateBadgeFrame() }
        }
    }
    
    /**
     * badgeLabel 最小尺寸
     */
    var badgeMinSize: CGFloat {
        get{
            return objc_getAssociatedObject(self, &view_badgeMinSizeKey) as? CGFloat ?? 8
        }
        set{
            objc_setAssociatedObject(self, &view_badgeMinSizeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { updateBadgeFrame() }
        }
    }
    
    /**
     *  badgeLabel OriginX
     */
    var badgeOriginX: CGFloat {
        get{
            return objc_getAssociatedObject(self, &view_badgeOriginXKey) as? CGFloat ?? 0
        }
        set{
            objc_setAssociatedObject(self, &view_badgeOriginXKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) {
                updateBadgeFrame()
            }
        }
    }
    
    /**
     * badgeLabel OriginY
     */
    var badgeOriginY: CGFloat  {
        get{
            return objc_getAssociatedObject(self, &view_badgeOriginYKey) as? CGFloat ?? -5
        }
        set{
            objc_setAssociatedObject(self, &view_badgeOriginYKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if (self.badgeLabel != nil) { updateBadgeFrame() }
        }
    }
    
    /**
     * In case of numbers, remove the badge when reaching zero
     */
    var shouldHideBadgeAtZero: Bool  {
        get {
            return objc_getAssociatedObject(self, &view_shouldHideBadgeAtZeroKey) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &view_shouldHideBadgeAtZeroKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
     * Badge has a bounce animation when value changes
     */
    var shouldAnimateBadge: Bool {
        get{
            return objc_getAssociatedObject(self, &view_shouldAnimateBadgeKey) as? Bool ?? true
        }
        set{
            objc_setAssociatedObject(self, &view_shouldAnimateBadgeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    fileprivate func badgeInit()  {
        if let label = self.badgeLabel {
            self.badgeOriginX = self.frame.size.width - label.frame.size.width/2
        }
        
        self.clipsToBounds = false
    }
    
    fileprivate func refreshBadge() {
        guard let tempLabel = self.badgeLabel else { return }
        tempLabel.textColor = self.badgeTextColor
        tempLabel.backgroundColor  = self.badgeBGColor
        tempLabel.font  = self.badgeFont
    }
    
    fileprivate func removeBadge() {
        UIView.animate(withDuration: 0.2, animations: {
            self.badgeLabel?.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        }) { (finished: Bool) in
            self.badgeLabel?.removeFromSuperview()
            if (self.badgeLabel != nil) { self.badgeLabel = nil }
        }
    }
    
    
    
    fileprivate func updateBadgeValue() {
        if self.shouldAnimateBadge && !(self.badgeLabel?.text == self.badgeValue) {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.5
            animation.toValue = 1
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
            self.badgeLabel?.layer.add(animation, forKey: "bounceAnimation")
        }
        
        if badgeType == BadgeType.Text {
            var badgeValue = 0
            if let badgeStr = self.badgeValue , let value = Int(badgeStr) {
                badgeValue = value
            }
            self.badgeLabel?.text = badgeValue >= 99 ? "99+" : self.badgeValue
            self.badgeLabel?.text =  self.badgeValue
            self.badgeLabel?.textAlignment = .center
        }
        self.updateBadgeFrame()
        
    }
    
    fileprivate  func updateBadgeFrame() {
        let expectedLabelSize: CGSize = badgeExpectedSize()
        var minHeight: CGFloat = expectedLabelSize.height
        minHeight = (minHeight < badgeMinSize) ? badgeMinSize : expectedLabelSize.height
        
        var minWidth: CGFloat = expectedLabelSize.width
        let padding = self.badgePadding
        minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width
        
        
        self.badgeLabel?.frame = CGRect(x: self.badgeOriginX, y: self.badgeOriginY, width: minWidth + padding, height: minHeight + padding)
        self.badgeLabel?.layer.cornerRadius = (minHeight + padding) / 2
        self.badgeLabel?.layer.masksToBounds = true
    }
    
    fileprivate func badgeExpectedSize() -> CGSize {
        let frameLabel: UILabel = duplicate(self.badgeLabel)
        frameLabel.sizeToFit()
        let expectedLabelSize: CGSize = frameLabel.frame.size
        return expectedLabelSize
    }
    
    fileprivate func duplicate(_ labelToCopy: UILabel? ) -> UILabel {
        guard let temp = labelToCopy else { fatalError("xxxx") }
        let duplicateLabel = UILabel(frame: temp.frame )
        duplicateLabel.text = temp.text
        duplicateLabel.font = temp.font
        return duplicateLabel
    }
    
    
}

extension UIView {
   
    func snapshotImage() -> UIImage {
        let size = bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let rect = bounds
        drawHierarchy(in: rect, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
}
