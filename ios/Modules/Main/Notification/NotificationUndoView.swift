//
//  NotificationUndoView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/12.
//

import UIKit

class NotificationUndoView: UIView {

  var remaingCount = 5
  var undoHandler:(()->())?
  var timer:Timer!
  var countLabel = UILabel()
  var undButton = UIButton()
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = R.color.theamRed()
   
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startCount), userInfo: nil, repeats: true)
    addSubview(remaingCountIndicator)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  @objc func startCount() {
    if remaingCount == 0 {
      if timer != nil {
        timer.invalidate()
        timer = nil
      }
      return
    }
    remaingCount -= 1
  }
  
  func dismiss() {
    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
      self.alpha = 0
    } completion: { flag in
      self.removeFromSuperview()
    }

  }

  static func show(_ undoCount:Int,_ undoHandler:@escaping ()->()) {
    let undoView = NotificationUndoView()
    undoView.undoHandler = undoHandler
    undoView.dismiss()
    
    let window = UIApplication.shared.keyWindow
    window?.addSubview(undoView)
    
    undoView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: 44)
    undoView.alpha = 0
    
    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
      undoView.alpha = 1
    } completion: { flag in
      
    }

  }
}
