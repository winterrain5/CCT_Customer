//
//  ServiceDetailApproachCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit

class ServiceDetailApproachCell: UITableViewCell {
  
  @IBOutlet weak var topImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  
  var model:ServiceApproaches! {
    didSet {
      topImageView.yy_setImage(with: model.thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
      titleLabel.text = model.title
      descLabel.text = model.description
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    descLabel.textAlignment = .center
  }
  
  
  
}
