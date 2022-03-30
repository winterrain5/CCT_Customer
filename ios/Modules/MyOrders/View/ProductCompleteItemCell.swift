//
//  ProductCompleteItemCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class ProductCompleteItemCell: UITableViewCell {
  
  @IBOutlet weak var productImageView: UIImageView!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  @IBOutlet weak var pointsLabel: UILabel!
  @IBOutlet weak var priceWCons: NSLayoutConstraint!
  var leaveReviewHandler:((OrderLineInfo)->())?
  var model:OrderLineInfo! {
    didSet {
      productImageView.yy_setImage(with: model.picture?.asURL, options: .setImageWithFadeAnimation)
      numLabel.text = (model.qty?.removingSuffix(".00") ?? "") + " x"
      nameLabel.text = model.name
      priceLabel.text = "$" + (model.price ?? "")
      pointsLabel.text = "Leave a review and recieved \(model.leave_review_points ?? "") loyalty points"
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
  @IBAction func leaveReviewButtonAction(_ sender: Any) {
    leaveReviewHandler?(model)
  }
  
}
