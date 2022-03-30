//
//  SymptomCheckPlanCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/17.
//

import UIKit

class SymptomCheckPlanCell: UITableViewCell {
  
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var headImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  
  @IBOutlet weak var priceLabel: UILabel!
  var model:SymptomCheckPlanModel? {
    didSet {
      guard let model = model else {
        return
      }
      if model.type == 0 {
        titleLabel.text = "Complicated"
        descLabel.text = model.complicated_description
        headImageView?.yy_setImage(with:model.complicated_img?.asURL, options: .setImageWithFadeAnimation)
        durationLabel.text = "\(model.complicated_duration ?? "") mins"
        priceLabel.text = model.complicated_retail_price?.dolar
      }
      if model.type == 1 {
        titleLabel.text = "Interelated"
        descLabel.text = model.interelated_description
        headImageView?.yy_setImage(with: model.interelated_img?.asURL, options: .setImageWithFadeAnimation)
        durationLabel.text = "\(model.interelated_duration ?? "") mins"
        priceLabel.text = model.interelated_retail_price?.dolar
      }
      if model.type == 2 {
        titleLabel.text = "Targeted"
        descLabel.text = model.targeted_description
        headImageView?.yy_setImage(with: model.targeted_img?.asURL, options: .setImageWithFadeAnimation)
        durationLabel.text = "\(model.targeted_duration ?? "") mins"
        priceLabel.text = model.targeted_retail_price?.dolar
      }
      
      setNeedsLayout()
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    headImageView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
}
