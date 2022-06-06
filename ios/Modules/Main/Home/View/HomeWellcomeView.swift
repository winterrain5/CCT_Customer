//
//  HomeWellcomView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/6.
//

import UIKit

class HomeWellcomeView: UIView {

  var nameLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 24)
    label.text = "Wellcome," + (Defaults.shared.get(for: .userModel)?.last_name ?? "")
  }
  var tipLabel = UILabel().then { label in
    label.textColor = R.color.black()
    label.font = UIFont(name: .AvenirNextRegular, size: 14)
    label.text = "Start exploring our integrated healthcare app!"
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(nameLabel)
    addSubview(tipLabel)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    nameLabel.snp.makeConstraints { make in
      make.right.left.equalToSuperview().inset(24)
      make.top.equalToSuperview().offset(16)
      make.height.equalTo(36)
    }
    tipLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalTo(nameLabel.snp.bottom)
    }
  }
}
