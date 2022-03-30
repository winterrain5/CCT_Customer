//
//  SymptomCheckStepCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckStepCell: UITableViewCell {

  private var titleLabel = UILabel().then { label in
    label.font = UIFont(.AvenirHeavy,16)
    label.textAlignment = .center
    label.cornerRadius = 16
    label.text = "Difficulty In Moving"
  }
  var model:SymptomCheckStepModel! {
    didSet {
      titleLabel.text = model.title
      if model.isSelected ?? false {
        titleLabel.backgroundColor = R.color.placeholder()
        titleLabel.textColor = R.color.theamRed()
      }else {
        titleLabel.backgroundColor = .white
        titleLabel.textColor = UIColor(hexString: "#BDBDBD")
      }
    }
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = .white
    contentView.addSubview(titleLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.top.bottom.equalToSuperview().inset(4)
    }
  }
 
}
