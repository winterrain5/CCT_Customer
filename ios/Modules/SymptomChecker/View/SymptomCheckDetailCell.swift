//
//  SymptomCheckDetailCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckDetailCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var reasonLabel: UILabel!
  @IBOutlet weak var exampleImageView: UIImageView!
  
  var model:SymptomCheckQ23ResultModel! {
    didSet {
      titleLabel.text = model.title
      exampleImageView.yy_setImage(with: model.thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
      descLabel.text = model.overview_describe
      reasonLabel.text = model.common_causes
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    titleLabel.textAlignment = .center
  }
  
}
