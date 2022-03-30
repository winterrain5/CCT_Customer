//
//  RewardsDetailContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

enum RewardDetailViewType {
  case watch
  case redeem
}

class RewardsDetailContainer: UIView {

  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var pointsLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var termsLabel: UILabel!
  @IBOutlet weak var redeemButton: UIButton!
  @IBOutlet weak var contentHCons: NSLayoutConstraint!
  @IBOutlet weak var pointsHCons: NSLayoutConstraint!
  var voucher:WalletVouchersModel? {
    didSet {
      titleLabel.text = voucher?.name
      descLabel.text = voucher?.description
    }
  }
  var coupon:WalletCouponsModel? {
    didSet {
      titleLabel.text = coupon?.name
      descLabel.text = coupon?.description
    }
  }
  var type:RewardDetailViewType = .watch {
    didSet {
      if type == .watch {
        redeemButton.isHidden = true
        pointsHCons.constant = 0
      }else {
        redeemButton.isHidden = false
        pointsHCons.constant = 24
      }
      layoutIfNeeded()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    termsLabel.text = "·Redemptions are only valid at Chien Chi Tow and Madam outlets\n·To redeem voucher, inform our counter staff during payment or use it for in-app store purchases\n·E-Vouchers are non-refundable and not allowed for cancellations\n·Valid for 1 year from date of redeption"
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func redeemButtonAction(_ sender: Any) {
    
  }
}
