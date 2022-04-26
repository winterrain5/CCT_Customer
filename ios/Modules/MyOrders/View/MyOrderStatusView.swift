//
//  MyOrderStatusView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/26.
//

import UIKit

class MyOrderStatusView: UIView {

  var statusLabel = UILabel().then { label in
    label.textColor = .white
    label.cornerRadius = 13
    label.font = UIFont(.AvenirNextDemiBold,12)
    label.textAlignment = .center
  }
  var textLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextDemiBold,24)
    label.text = "Order Summary"
    label.textAlignment = .center
  }
  var status:Int = 0 {
    didSet {
      
      if status == 0 {
        statusLabel.text = "In Progress"
        statusLabel.backgroundColor = R.color.theamBlue()
      }
      if status == 1 {
        statusLabel.text = "Completed"
        statusLabel.backgroundColor = UIColor(hexString: "#38B46C")
      }
      if status == 2 {
        statusLabel.text = "Cancelled"
        statusLabel.backgroundColor = UIColor(hexString: "#E0E0E0")
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(statusLabel)
    addSubview(textLabel)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    statusLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.width.equalTo(81)
      make.height.equalTo(26)
      make.top.equalToSuperview().offset(24)
    }
    textLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.height.equalTo(36)
      make.top.equalToSuperview().offset(54)
    }
  }
}
