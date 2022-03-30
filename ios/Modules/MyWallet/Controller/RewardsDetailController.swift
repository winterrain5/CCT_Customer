//
//  RewardsDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

class RewardsDetailController: BaseViewController {
  
  var contentView = RewardsDetailContainer.loadViewFromNib()
  var type:RewardDetailViewType = .watch
  var voucher:WalletVouchersModel?
  var coupon:WalletCouponsModel?
  convenience init(type:RewardDetailViewType,voucher:WalletVouchersModel? = nil,coupon:WalletCouponsModel? = nil) {
    self.init()
    self.type = type
    self.voucher = voucher
    self.coupon = coupon
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.bar.alpha = 0
    
    self.view.addSubview(contentView)
    
    contentView.frame = self.view.bounds
    contentView.type = type
    if let model = voucher {
      contentView.voucher = model
    }
    if let model = coupon {
      contentView.coupon = model
    }
    
  }
  
  
  
}
