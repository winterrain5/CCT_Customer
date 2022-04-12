//
//  MadamPartumProductItemCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit

class ShopProductItemCell: UICollectionViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var starContentView: StarRateView!
  @IBOutlet weak var likeButton: UIButton!
  
  var likeHandler:((ShopProductModel)->())?
  var model:ShopProductModel! {
    didSet {
      titleLabel.text = model.alias.isEmpty ? model.name : model.alias
      imageView.yy_setImage(with: model.picture.asURL, options: .setImageWithFadeAnimation)
      priceLabel.text = model.sell_price.dolar
      likeButton.imageForNormal = model.isLike ? R.image.madam_partum_heart_like() : R.image.madam_partum_heart()
      starContentView.selectNumberOfStar = model.avg_rating.float() ?? 0
      
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
    if model.isLike {
      self.deleteLikeProduct()
    }else {
      self.saveLikeProduct()
    }
   
  }
  
  func saveLikeProduct() {
    let params = SOAPParams(action: .Product, path: .saveLikeProduct)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "productId", value: model.id)
    
    NetworkManager().request(params: params) { data in
      self.model.isLike = true
      self.likeHandler?(self.model)
    } errorHandler: { e in
      
    }

  }
  
  func deleteLikeProduct() {
    let params = SOAPParams(action: .Product, path: .deleteLikeProduct)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "productId", value: model.id)
    
    NetworkManager().request(params: params) { data in
      self.model.isLike = false
      self.likeHandler?(self.model)
    } errorHandler: { e in
      
    }
  }
}
