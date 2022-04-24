//
//  ShopProductItemCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class ProductItemCell: UITableViewCell {

  @IBOutlet weak var productImageView: UIImageView!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var priceWCons: NSLayoutConstraint!
  
  var model:OrderLineInfo! {
    didSet {
      productImageView.yy_setImage(with: model.picture?.asURL, options: .setImageWithFadeAnimation)
      numLabel.text = (model.qty?.removingSuffix(".00") ?? "") + " x"
      nameLabel.text = model.name
      priceLabel.text = model.price?.float()?.string.dolar ?? ""
      priceWCons.constant = priceLabel.sizeThatFits(CGSize(width: CGFloat.infinity, height: 20)).width
      layoutIfNeeded()
    }
  }
  var product:Product! {
    didSet {
      productImageView.yy_setImage(with: product.picture.asURL, options: .setImageWithFadeAnimation)
      numLabel.text = product.count.string + " x"
      nameLabel.text = product.alias.isEmpty ? product.name : product.alias
      priceLabel.text = product.sell_price.formatMoney().dolar
      priceWCons.constant = priceLabel.sizeThatFits(CGSize(width: CGFloat.infinity, height: 20)).width
      layoutIfNeeded()
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
    
}
