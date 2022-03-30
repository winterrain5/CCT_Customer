//
//  SymptomCheckStepTitleView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckStepTitleView: UIView {
  var progress = StepProgressBar()
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(progress)
    progress.backgroundColor = .clear
    progress.color = .white
    progress.bgColor = UIColor(hexString: "#BDBDBD")!.withAlphaComponent(0.2)
    progress.stepsCount = 4
    progress.cornerRadius = 2
    progress.stepsOffset = 2
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    progress.frame = bounds
  }
  override var intrinsicContentSize: CGSize {
    CGSize(width: kScreenWidth - 180, height: 4)
  }
  
  
}
