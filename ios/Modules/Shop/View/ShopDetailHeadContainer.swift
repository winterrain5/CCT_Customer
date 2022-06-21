//
//  ShopDetailHeadContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/13.
//

import UIKit

class ShopDetailHeadContainer: UIView {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var starRateView: StarRateView!
  @IBOutlet weak var stepperView: ShopStepperView!
  @IBOutlet weak var starPointLabel: UILabel!
  @IBOutlet weak var infoContentView: UIView!
  var updateHeightHandler:((CGFloat)->())?
  var product:Product? {
    didSet {
      guard let model = product else { return }
      hideSkeleton()
      nameLabel.text = model.alias.isEmpty ? model.name : model.alias
      imageView.yy_setImage(with: model.picture.asURL, options: .setImageWithFadeAnimation)
      priceLabel.text = model.sell_price.dolar
      starRateView.selectNumberOfStar = model.avg_rating.float() ?? 0
      starPointLabel.text = model.avg_rating
      
      updateHeightHandler?(nameLabel.requiredHeight + 525)
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    showSkeleton()
    starRateView.selectStarUnit = .custom
    starRateView.hightLightImage = R.image.madam_partum_star()
    starRateView.defaultImage = R.image.madam_partum_un_star()
    stepperView.valueDidChangeHandler = { [weak self] count in
      self?.product?.count = count
    }
    stepperView.enableValueToZero = false
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    infoContentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
}
