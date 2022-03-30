//
//  WalletTransactionSectionView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/3.
//

import UIKit

class WalletTransactionSectionView: UIView {
  var model:WalletTranscationModel! {
    didSet {
      
      let date = model.due_date?.date(withFormat: "yyyy-MM-dd")
      if date?.isInToday ?? false {
        label.text = "Today"
      }else {
        label.text = date?.string(withFormat: "dd MMM yyyy")
      }
    }
  }
  var label = UILabel().then { label in
    label.text = "8 Dec 2020"
    label.textColor = .black
    label.font = UIFont(.AvenirNextDemiBold,13)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor(hexString: "f2f2f2")
    addSubview(label)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.bottom.top.right.equalToSuperview()
    }
  }
}
