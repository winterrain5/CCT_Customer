//
//  WalletDetailHeadView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

class WalletDetailHeadView: UIView {
  
  
  @IBOutlet weak var cardContainer: UIView!
  @IBOutlet weak var privilegesLabel: UILabel!
  let card = WalletCardView.loadViewFromNib()
  var updateHeightHandler:((CGFloat)->())?
  var models:[CardPrivilegesModel] = [] {
    didSet {
      let str = NSMutableAttributedString(string: "")
      models.forEach { model in
        let attr = NSMutableAttributedString(string: "· \(model.discount_percent ?? "")% off \(model.sale_category_title ?? "")\n")
        attr.addAttribute(.font, value: UIFont(.AvenirNextDemiBold,16), range: NSRange(location: 0, length: 1))
        attr.addAttribute(.font, value: UIFont(.AvenirNextRegular,14), range: NSRange(location: 1, length: attr.string.count - 1))
        str.append(attr)
      }
      privilegesLabel.attributedText = str
      updateHeightHandler?(privilegesLabel.requiredHeight + 295)
      hideSkeleton()
    }
  }
  @IBAction func viewTiersButtonAction(_ sender: Any) {
    let vc = TierPrivilegesController()
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    cardContainer.addSubview(card)
    isSkeletonable = true
    showSkeleton()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    card.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  
}
