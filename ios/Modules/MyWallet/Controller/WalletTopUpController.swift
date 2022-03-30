//
//  WalletTopUpController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/10.
//

import UIKit

class WalletTopUpController: BaseViewController {
  var contentView = WalletTopUpContainer.loadViewFromNib()
    override func viewDidLoad() {
        super.viewDidLoad()

      self.navigation.item.title = "Top Up"
      self.view.addSubview(contentView)
      contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }
    

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.contentView.reloadPaymentMethod()
  }

}
