//
//  SymptomCheckStepHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckStepHeaderView: UIView {
  private var label = UILabel().then { label in
    label.textColor = .white
    label.lineHeight = 36
    label.font = UIFont(name: .AvenirNextDemiBold, size:24)
    label.numberOfLines = 0
  }
  var title:String = "" {
    didSet {
      label.text = title
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = R.color.theamBlue()
    addSubview(label)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(32)
    }
  }

}
