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
  var countLabel = UILabel().then { label in
    label.textColor = .white
    label.font = UIFont(.AvenirNextRegular,16)
    label.text = "0 Delete"
  }
  var undoButton = UIButton().then { btn in
    btn.titleForNormal = "Undo"
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,16)
  }
  var deleteCount:Int = 0 {
    didSet {
      countLabel.text = "\(deleteCount) Delete"
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = R.color.theamRed()
    addSubview(countLabel)
    addSubview(undoButton)
    undoButton.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startCount), userInfo: nil, repeats: true)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    countLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(16)
    }
    
    undoButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-16)
    }
  }
  
  @objc func undoAction() {
    undoHandler?()
  }
  
  @objc func startCount() {
    if remaingCount == 0 {
      if timer != nil {
        timer.invalidate()
        timer = nil
        dismiss()
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

  static func show(count:Int,_ undoHandler:@escaping ()->()) {
    let undoView = NotificationUndoView()
    undoView.undoHandler = undoHandler
    undoView.deleteCount = count
    
    
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
