//
//  ShopStepperView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit

class ShopStepperView: UIView {

  lazy var decreaseButton = UIButton().then { btn in
    btn.cornerRadius = 13
    btn.imageForNormal = R.image.shop_decrease()
    btn.addTarget(self, action: #selector(decreaseAction(_:)), for: .touchUpInside)
  }
  
  lazy var increaseButton = UIButton().then { btn in
    btn.cornerRadius = 13
    btn.imageForNormal = R.image.shop_increase()
    btn.addTarget(self, action: #selector(increaseAction(_:)), for: .touchUpInside)
  }
  
  lazy var valueLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size:14)
    label.textAlignment = .center
  }
  private var value:Int = 1
  var count:Int = 1 {
    didSet {
      self.value = count
      updateValue()
    }
  }
  var valueDidChangeHandler:((Int)->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
  }
  
  func setupViews() {
    backgroundColor = .clear
    addSubview(decreaseButton)
    addSubview(increaseButton)
    addSubview(valueLabel)
    updateValue()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    decreaseButton.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(26)
    }
    increaseButton.snp.makeConstraints { make in
      make.right.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.height.equalTo(26)
    }
    valueLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.left.equalTo(decreaseButton.snp.right)
      make.right.equalTo(increaseButton.snp.left)
    }
  }
  
  @objc func decreaseAction(_ sender:UIButton) {
    if value == 0 {
      return
    }
    value -= 1
    updateValue()
  }
  
  @objc func increaseAction(_ sender:UIButton) {
    if value == 100 {
      return
    }
    value += 1
    updateValue()
  }
  
  func updateValue() {
    valueDidChangeHandler?(value)
    valueLabel.text = value.string
  }
}
