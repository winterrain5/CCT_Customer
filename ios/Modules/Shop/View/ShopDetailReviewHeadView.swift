//
//  ShopDetailReviewHeadView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/14.
//

import UIKit

class ShopDetailReviewHeadView: UIView {
  
  var customerNumLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(.AvenirNextDemiBold,13)
    label.isSkeletonable = true
    label.lineHeight = 12
    label.textAlignment = .center
  }
  var ratingLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(.AvenirNextDemiBold,24)
    label.isSkeletonable = true
    label.lineHeight = 36
    label.textAlignment = .center
  }
  var rateView = StarRateView().then { view in
    view.selectStarUnit = .custom
    view.hightLightImage = R.image.madam_partum_star()
    view.defaultImage = R.image.madam_partum_un_star()
  }
  var headLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextDemiBold,18)
    label.isSkeletonable = true
    label.text = "Customer Ratings"
    label.lineHeight = 28
  }
  
  var model:ShopProductDetailModel! {
    didSet {
      hideSkeleton()
      customerNumLabel.text = "\(model.Counts?.counts ?? "") Customer Ratings"
      rateView.selectNumberOfStar = model.Product?.avg_rating.float() ?? 0
      ratingLabel.text = model.Product?.avg_rating
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    isSkeletonable = true
    showSkeleton()
    addSubview(customerNumLabel)
    addSubview(ratingLabel)
    addSubview(rateView)
    addSubview(headLabel)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    customerNumLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalToSuperview().offset(32)
    }
    ratingLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalTo(customerNumLabel.snp.bottom).offset(8)
    }
    rateView.snp.makeConstraints { make in
      make.width.equalTo(85)
      make.height.equalTo(15)
      make.top.equalTo(ratingLabel.snp.bottom).offset(8)
      make.centerX.equalToSuperview()
    }
    headLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().offset(-8)
    }
  }

}
