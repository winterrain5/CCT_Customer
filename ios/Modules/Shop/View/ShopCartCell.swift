//
//  ShopCartCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit
import SwipeCellKit
class ShopCartCell: SwipeTableViewCell {

  @IBOutlet weak var productNameLabel: UILabel!
  @IBOutlet weak var productImageView: UIImageView!
  
  @IBOutlet weak var stepperView: ShopStepperView!
  @IBOutlet weak var priceLabel: UILabel!
  var updateProductCountHandler:((ShopCartModel)->())?
  var cart:ShopCartModel! {
    didSet {
      productNameLabel.text = cart.alias.isEmpty ? cart.name : cart.alias
      productImageView.yy_setImage(with: cart.picture.asURL, options: .setImageWithFadeAnimation)
      priceLabel.text = cart.sell_price.formatMoney().dolar
      stepperView.count = cart.goods_num
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    stepperView.valueDidChangeHandler = { [weak self] count in
      guard let `self` = self else { return }
      self.cart.goods_num = count
      self.updateProductCountHandler?(self.cart)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
}
