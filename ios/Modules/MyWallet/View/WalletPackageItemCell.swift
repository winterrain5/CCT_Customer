//
//  WalletPackageCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/8/10.
//

import UIKit

class WalletPackageItemCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var expiresDateLabel: UILabel!
  @IBOutlet weak var remainingTimeLabel: UILabel!
  var package:WalletPackagesModel! {
    didSet {
      titleLabel.text = package.name
      descLabel.text = package.desc
      imageView.yy_setImage(with: package.thumbnail_img.asURL, options: .setImageWithFadeAnimation)
      expiresDateLabel.text = "(Expires \(package.expiry_period_date.date(withFormat: "yyyy-MM-dd")?.string(withFormat: "dd MMM yyyy") ?? ""))"
      let str = "Sessions Remaining: \(package.item.count)"
      let attr = NSMutableAttributedString(string: str)
      attr.addAttribute(.font, value: UIFont(name: .AvenirNextRegular, size: 12), range: NSRange(location: 0, length: str.count - package.item.count.string.count))
      attr.addAttribute(.font, value: UIFont(name: .AvenirNextBold, size: 12), range: NSRange(location: str.count - package.item.count.string.count, length: package.item.count.string.count))
      remainingTimeLabel.attributedText = attr
      
    }
  }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
