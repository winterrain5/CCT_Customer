//
//  ShopProductReviewCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/14.
//

import UIKit

class ShopProductReviewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var commentLabel: UILabel!
  @IBOutlet weak var starPointLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  var model:Reviews! {
    didSet {
      nameLabel.text = model.first_name + " " + model.last_name
      starPointLabel.text = model.rating
      commentLabel.text = model.review_content
      dateLabel.text = model.create_time.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMMM yyyy")
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
  
}
