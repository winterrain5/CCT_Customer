//
//  ShopCartCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit

class ShopCartCell: UITableViewCell {

  @IBOutlet weak var productNameLabel: UILabel!
  @IBOutlet weak var productImageView: UIImageView!
  
  @IBOutlet weak var stepperView: ShopStepperView!
  @IBOutlet weak var priceLabel: UILabel!
  var updateCellIsLikeStatus:((ShopProductModel)->())?
  var model:ShopProductModel! {
    didSet {
      productNameLabel.text = model.alias.isEmpty ? model.name : model.alias
      productImageView.yy_setImage(with: model.picture.asURL, options: .setImageWithFadeAnimation)
      priceLabel.text = model.sell_price.formatMoney().dolar
      
      
    }
  }
}
