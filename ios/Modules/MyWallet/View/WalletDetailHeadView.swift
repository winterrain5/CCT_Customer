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
  var model:CardDiscountDetailModel! {
    didSet {
      let str = NSMutableAttributedString(string: "")
      
      let attr1 = NSMutableAttributedString(string: "· \(model.r_discount1 ?? "")\n")
      attr1.addAttribute(.font, value: UIFont(.AvenirNextDemiBold,16), range: NSRange(location: 0, length: 1))
      attr1.addAttribute(.font, value: UIFont(.AvenirNextRegular,14), range: NSRange(location: 1, length: attr1.string.count - 1))
      str.append(attr1)
      
      let attr2 = NSMutableAttributedString(string: "· \(model.r_discount2 ?? "")\n")
      attr2.addAttribute(.font, value: UIFont(.AvenirNextDemiBold,16), range: NSRange(location: 0, length: 1))
      attr2.addAttribute(.font, value: UIFont(.AvenirNextRegular,14), range: NSRange(location: 1, length: attr2.string.count - 1))
      str.append(attr2)
      
      let attr3 = NSMutableAttributedString(string: "· \(model.r_discount3 ?? "")\n")
      attr3.addAttribute(.font, value: UIFont(.AvenirNextDemiBold,16), range: NSRange(location: 0, length: 1))
      attr3.addAttribute(.font, value: UIFont(.AvenirNextRegular,14), range: NSRange(location: 1, length: attr3.string.count - 1))
      
      str.append(attr3)
      
      privilegesLabel.attributedText = str
      updateHeightHandler?(privilegesLabel.requiredHeight + 295)
      hideSkeleton()
    }
  }
  @IBAction func viewTiersButtonAction(_ sender: Any) {
    let vc = TierPrivilegesController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
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
