//
//  CKEntryKit.swift
//  ClassRoomKit
//
//  Created by VICTOR03 on 2021/5/9.
//
import UIKit
import Foundation


public enum EntryStyle {
  case sheet
  case alert
}

open class EntryKit:UIView {
  private static let animateDuration:TimeInterval = 0.5
  private static let animateDamping:CGFloat = 0.9
  private static let animateVelocity:CGFloat = 2
  private static var style:EntryStyle = .alert
  private static var touchDismiss:Bool = true
  private static var childView: UIView!
  public static var dismissHandler:(()->())?
  public static func display(view:UIView,
                             size:CGSize,
                             style:EntryStyle,
                             backgroundColor:UIColor,
                             touchDismiss:Bool) {
    innerDisplay(view: view, size: size, style: style, backgroundColor:backgroundColor,touchDismiss: touchDismiss)
  }
  
  public static func display(view:UIView,
                             size:CGSize,
                             style:EntryStyle,
                             touchDismiss:Bool) {
    innerDisplay(view: view, size: size, style: style, backgroundColor: UIColor.black.withAlphaComponent(0.8),touchDismiss: touchDismiss)
  }
  
  public static func display(view:UIView,
                             size:CGSize,
                             style:EntryStyle) {
    innerDisplay(view: view, size: size, style: style, backgroundColor: UIColor.black.withAlphaComponent(0.8),touchDismiss: true)
    
  }
  
  private static func innerDisplay(view:UIView,
                                   size:CGSize,
                                   style:EntryStyle,
                                   backgroundColor:UIColor,
                                   touchDismiss:Bool) {
    let superView = UIApplication.shared.keyWindow
    if (superView?.subviews.last?.isKind(of: EntryKit.self) ?? false) {
      return
    }
    
    EntryKit.style = style
    EntryKit.childView = view
    EntryKit.touchDismiss = touchDismiss
    
    let container = EntryKit()
    container.frame = UIScreen.main.bounds
    superView?.addSubview(container)
    
    container.addSubview(view)
    view.frame.size = size
    
    if style == .alert {
      view.center = view.superview?.center ?? .zero
      view.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
      UIView.animate(withDuration: EntryKit.animateDuration,
                     delay: 0,
                     usingSpringWithDamping: EntryKit.animateDamping,
                     initialSpringVelocity: EntryKit.animateVelocity,
                     options: .curveEaseIn,
                     animations: {
                      view.transform = CGAffineTransform.identity
                      container.backgroundColor = backgroundColor
                     }, completion: nil)
    }else {
      view.frame.origin = CGPoint(x: 0, y: kScreenHeight)
      UIView.animate(withDuration: EntryKit.animateDuration,
                     delay: 0,
                     usingSpringWithDamping: EntryKit.animateDamping,
                     initialSpringVelocity: EntryKit.animateVelocity,
                     options: .curveEaseIn,
                     animations: {
                      view.frame.origin = CGPoint(x: 0, y: kScreenHeight - size.height)
                      container.backgroundColor = backgroundColor
                     }, completion: nil)
    }
  }
  
  public static func dismiss(_ complete:(()->())? = nil) {
    let superView = UIApplication.shared.keyWindow?.subviews.last
    if !(superView?.isKind(of: EntryKit.self) ?? false) {
      return
    }
    let subView = EntryKit.childView
    if EntryKit.style == .alert {
      UIView.animate(withDuration: EntryKit.animateDuration,
                     delay: 0.1,
                     usingSpringWithDamping: EntryKit.animateDamping,
                     initialSpringVelocity: EntryKit.animateVelocity,
                     options: .curveEaseOut) {
        superView?.backgroundColor = .clear
        subView?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        subView?.alpha = 0
      } completion: { (flag) in
        superView?.removeFromSuperview()
        subView?.removeFromSuperview()
        complete?()
        dismissHandler?()
      }
    }else {
      UIView.animate(withDuration: EntryKit.animateDuration,
                     delay: 0.1,
                     usingSpringWithDamping: EntryKit.animateDamping,
                     initialSpringVelocity: EntryKit.animateVelocity,
                     options: .curveEaseOut) {
        superView?.backgroundColor = .clear
        subView?.frame.origin = CGPoint(x: 0, y: kScreenHeight)
      } completion: { (flag) in
        superView?.removeFromSuperview()
        subView?.removeFromSuperview()
        complete?()
        dismissHandler?()
      }
    }
  }
  
  public static func dismiss() {
    dismiss(nil)
  }
  

  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let point = touches.first?.location(in: self) ?? .zero
    if EntryKit.touchDismiss {
      if !EntryKit.childView.frame.contains(point) {
        EntryKit.dismiss()
      }
    }
  }
  
}
