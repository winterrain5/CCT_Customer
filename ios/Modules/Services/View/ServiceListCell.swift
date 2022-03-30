//
//  ServiceListCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import UIKit

class ServiceListCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var serviceNameLabel: UILabel!
  @IBOutlet weak var serviceDescriptionLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var priceTimeContainer: UIView!
  @IBOutlet weak var descTopCons: NSLayoutConstraint!
  @IBOutlet weak var onlyPriceView: UIView!
  @IBOutlet weak var onlyPriceLabel: UILabel!
  @IBOutlet weak var priceTimeView: UIView!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var tagContainer: ServicesTagView!
  @IBOutlet weak var tagHCons: NSLayoutConstraint!
  var model:OurServicesByCategoryModel? {
    didSet {
      guard let model = model else { return }
      if let url = model.part1_thumbnail_img?.asURL {
        imageView.yy_setImage(with:url, options: .setImageWithFadeAnimation)
      }
      serviceNameLabel.text = model.name
      serviceDescriptionLabel.text = model.service_description
      
      if let tags = model.approaches?.map({ $0.title ?? "" }),tags.isEmpty == false {
        tagContainer.isHidden = false
        tagContainer.tags = tags
        tagHCons.constant = 24
      }else {
        tagHCons.constant = 0
        tagContainer.isHidden = true
      }
      
      
      if let minPrice = model.service_duration?.min_price?.formatMoney().dolar,
      let maxPrice = model.service_duration?.max_price?.formatMoney().dolar,
      let minDuration = model.service_duration?.min_duration,
      let maxDuration = model.service_duration?.max_duration  {
        onlyPriceView.isHidden = false
        priceTimeView.isHidden = false
        descTopCons.constant = 34
        
        onlyPriceLabel.text = minPrice + "-" + maxPrice
        priceLabel.text = minPrice
        timeLabel.text = minDuration + " mins"
      }else {
        onlyPriceView.isHidden = true
        priceTimeView.isHidden = true
        descTopCons.constant = 10
      }
      
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    imageView.roundCorners([.topLeft,.topRight], radius: 16)
  }
  
}
