//
//  ShopDetailAboutHeadView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/13.
//

import UIKit

class ShopDetailAboutHeadView: UIView {

  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var suitableLabel: UILabel!
  var updateHeightHandler:((CGFloat)->())!
  var model:ShopProductDetailModel! {
    didSet {
      hideSkeleton()
      
      descLabel.text = model.Product?.how_help
      suitableLabel.text = model.Product?.suitable_for_who
      
      let descH = descLabel.requiredHeight
      let suitableHeight = suitableLabel.requiredHeight
      
      let total = descH + suitableHeight + 196
      updateHeightHandler(total)
      
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    showSkeleton()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
   
  }

}
