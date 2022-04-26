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
  var updateProductCountHandler:(()->())?
  var model:Product! {
    didSet {
      productNameLabel.text = model.alias.isEmpty ? model.name : model.alias
      productImageView.yy_setImage(with: model.picture.asURL, options: .setImageWithFadeAnimation)
      priceLabel.text = model.sell_price.formatMoney().dolar
      stepperView.count = model.count
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    stepperView.valueDidChangeHandler = { [weak self] count in
      guard let `self` = self else { return }
      self.model.count = count
      self.updateProductCountHandler?()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
}
