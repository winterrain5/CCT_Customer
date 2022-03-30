//
//  ServiceDetailHelpCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit

class ServiceDetailHelpCell: UITableViewCell {

  @IBOutlet weak var leftImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  
  var model:BriefHelpItems! {
    didSet {
      leftImageView.yy_setImage(with: model.thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
      titleLabel.text = model.title
      descLabel.text = model.description
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
