//
//  WalletDetailFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

class WalletDetailFooterView: UIView {

  var lineView = UIView().then { view in
    view.backgroundColor = R.color.line()
  }
  var label = UILabel().then { label in
    label.text = "Terms and Conditions"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextDemiBold,18)
  }
  var arrowButton = UIButton().then { btn in
    btn.imageForNormal = R.image.account_arrow_right()
    btn.contentHorizontalAlignment = .right
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(lineView)
    addSubview(label)
    addSubview(arrowButton)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    lineView.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
      make.height.equalTo(1)
    }
    label.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalToSuperview()
    }
    arrowButton.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(24)
      make.top.bottom.equalToSuperview()
      make.width.equalTo(kScreenWidth - 24)
    }
  }
  
  @objc func arrowButtonAction() {
    
  }
}
