//
//  WalletVoucherCouponsCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

class WalletVoucherCouponsCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  var voucher:WalletVouchersModel! {
    didSet {
      titleLabel.text = voucher.name
      descLabel.text = voucher.description
      
    }
  }
  var coupon:WalletCouponsModel! {
    didSet {
      titleLabel.text = coupon.name
      descLabel.text = coupon.description
      imageView.yy_setImage(with: coupon.img?.asURL, options: .setImageWithFadeAnimation)
    }
  }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
