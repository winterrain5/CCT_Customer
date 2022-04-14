//
//  ShopDetialBottomView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/14.
//

import UIKit

class ShopDetialBottomView: UIView {

  var addToCartButton = UIButton().then { btn in
    btn.backgroundColor = R.color.grayE0()
    btn.cornerRadius = 22
    btn.titleForNormal = "Add to Cart"
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.titleColorForNormal = R.color.black333()
  }
  var buyNowButton = UIButton().then { btn in
    btn.backgroundColor = R.color.theamRed()
    btn.cornerRadius = 22
    btn.titleForNormal = "Buy Now"
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
  }
  var addToCartHandler:(()->())!
  var buyNowHandler:(()->())!
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(addToCartButton)
    addToCartButton.addTarget(self, action: #selector(addToCartAction), for: .touchUpInside)
    addSubview(buyNowButton)
    buyNowButton.addTarget(self, action: #selector(buyNowAction), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
   
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let btnW = (kScreenWidth - 80) * 0.5
    addToCartButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(32)
      make.width.equalTo(btnW)
      make.height.equalTo(44)
      make.top.equalToSuperview().offset(16)
    }
    buyNowButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-32)
      make.width.equalTo(btnW)
      make.height.equalTo(44)
      make.top.equalToSuperview().offset(16)
    }
  }
  
  @objc func addToCartAction() {
    addToCartHandler()
  }
  
  @objc func buyNowAction() {
    buyNowHandler()
  }
}
