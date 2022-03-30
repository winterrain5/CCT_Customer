//
//  MadamPartumProductItemCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit

class MadamPartumProductItemCell: UICollectionViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var starContentView: StarRateView!
  @IBOutlet weak var likeButton: UIButton!
  
  var likeHandler:((FeatureProductModel)->())?
  var model:FeatureProductModel! {
    didSet {
      titleLabel.text = model.name
      imageView.yy_setImage(with: model.picture?.asURL, options: .setImageWithFadeAnimation)
      priceLabel.text = model.sell_price?.dolar
      likeButton.imageForNormal = (model.isLike ?? false) ? R.image.madam_partum_heart_like() : R.image.madam_partum_heart()
      starContentView.selectNumberOfStar = model.avg_rating?.float() ?? 0
      
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    starContentView.selectStarUnit = .custom
    starContentView.hightLightImage = R.image.madam_partum_star()
    starContentView.defaultImage = R.image.madam_partum_un_star()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
   
  }
  
  @IBAction func likeButtinAction(_ sender: Any) {
    likeHandler?(model)
  }
}
