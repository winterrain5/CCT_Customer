//
//  FillInEnquiryFormView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/24.
//

import UIKit
import IQKeyboardManagerSwift
class FillInEnquiryFormView: UIView {

  var contentView = FillInEnquiryFormContentView.loadViewFromNib()

  var scrolview = UIScrollView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: 500)
    contentView.backHandler = { [weak self] in
      self?.dismiss()
    }
    contentView.submitHandler = { [weak self] in
      self?.dismiss()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        AlertView.show(message: "Your enquiry has been successfully sent!")
      }
    }
    
    scrolview.contentSize = CGSize(width: kScreenWidth, height: kScreenHeight)
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    scrolview.addGestureRecognizer(tap)
    
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  @objc func tapAction(_ ges:UIGestureRecognizer) {
    let location = ges.location(in: scrolview)
    if location.y < kScreenHeight - 500 {
     dismiss()
    }
  }
  
  func dismiss() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.contentView.frame.origin.y = kScreenHeight
      self.backgroundColor = .clear
    } completion: { flag in
      self.removeFromSuperview()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    scrolview.frame = self.bounds
    contentView.width = kScreenWidth
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  static func showView(from spView:UIView) {
    let view = FillInEnquiryFormView()
    view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    spView.addSubview(view)
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
      view.contentView.frame.origin.y = kScreenHeight - 500
    } completion: { flag in
      
    }
  }

}
