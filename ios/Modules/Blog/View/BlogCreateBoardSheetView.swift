//
//  BlogCreateBoardSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/9.
//

import UIKit

class BlogCreateBoardSheetView: UIView {

  var contentView = BlogCreateBoardSheetContentView.loadViewFromNib()
  let contentHeight:CGFloat = 295 + kBottomsafeAreaMargin
  var scrolview = UIScrollView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    scrolview.contentSize = CGSize(width: kScreenWidth, height: contentHeight)
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    scrolview.addGestureRecognizer(tap)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  @objc func tapAction(_ ges:UIGestureRecognizer) {
    let location = ges.location(in: scrolview)
    if location.y < (kScreenHeight - contentHeight) {
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
  
  func showView(from spView:UIView) {
    self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    spView.addSubview(self)
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
      self.contentView.frame.origin.y = kScreenHeight - self.contentHeight
    } completion: { flag in
      
    }
  }


}
