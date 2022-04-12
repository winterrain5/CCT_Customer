//
//  ShopLikeProductCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit

class ShopLikeProductCell: UITableViewCell {
  @IBOutlet weak var productNameLabel: UILabel!
  @IBOutlet weak var productImageView: UIImageView!
  
  @IBOutlet weak var shopLikeButton: UIButton!
  @IBOutlet weak var priceLabel: UILabel!
  var updateCellIsLikeStatus:((ShopProductModel)->())?
  var model:ShopProductModel! {
    didSet {
      productNameLabel.text = model.alias.isEmpty ? model.name : model.alias
      productImageView.yy_setImage(with: model.picture.asURL, options: .setImageWithFadeAnimation)
      priceLabel.text = model.sell_price.formatMoney().dolar
      shopLikeButton.imageForNormal = model.isLike ? R.image.madam_partum_heart_like() : R.image.madam_partum_heart()
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func shopLikeButtonAction(_ sender: UIButton) {
    if model.isLike {
      deleteLikeProduct()
    }else {
      saveLikeProduct()
    }
  
  }
  
  func saveLikeProduct() {
    let params = SOAPParams(action: .Product, path: .saveLikeProduct)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "productId", value: model.id)
    
    NetworkManager().request(params: params) { data in
      self.model.isLike = true
      self.updateCellIsLikeStatus?(self.model)
    } errorHandler: { e in
      
    }

  }
  
  func deleteLikeProduct() {
    let params = SOAPParams(action: .Product, path: .deleteLikeProduct)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "productId", value: model.id)
    
    NetworkManager().request(params: params) { data in
      self.model.isLike = false
      self.updateCellIsLikeStatus?(self.model)
    } errorHandler: { e in
      
    }
  }
  
}
