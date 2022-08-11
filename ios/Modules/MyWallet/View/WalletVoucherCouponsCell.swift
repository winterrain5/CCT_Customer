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
  @IBOutlet weak var expiresDateLabel: UILabel!
  var voucher:WalletVouchersModel! {
    didSet {
      titleLabel.text = voucher.name
      descLabel.text = voucher.desc
    }
  }
  var coupon:WalletCouponsModel! {
    didSet {
      titleLabel.text = coupon.name
      descLabel.text = coupon.desc
      imageView.yy_setImage(with: coupon.img?.asURL, options: .setImageWithFadeAnimation)
      expiresDateLabel.text = "(Expires \(coupon.expired_time?.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM yyyy") ?? ""))"
    }
  }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
