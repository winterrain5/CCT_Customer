//
//  MadamPartumDetailFooterCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/21.
//

import UIKit

class MadamPartumDetailFooterCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var rateLabel: UILabel!
  @IBOutlet weak var rateContainer: StarRateView!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  var model:ClientReviewModel! {
    didSet {
      nameLabel.text = model.client_name
      rateLabel.text = model.rating
      contentLabel.text = model.review_content
      dateLabel.text = model.create_time?.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMMM yyyy")
      rateContainer.selectNumberOfStar = model.rating?.float() ?? 0
    }
  }
    override func awakeFromNib() {
        super.awakeFromNib()
      rateContainer.selectStarUnit = .custom
    }

}
