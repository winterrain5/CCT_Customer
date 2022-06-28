//
//  ShopDetailAboutHeadView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/13.
//

import UIKit

class ShopDetailAboutHeadView: UIView {

  @IBOutlet weak var descLabel: UILabel!

  var updateHeightHandler:((CGFloat)->())!
  var model:ShopProductDetailModel! {
    didSet {
      hideSkeleton()
      
      descLabel.text = model.Product?.how_help
      
      let descH = descLabel.requiredHeight
      
      let total = descH + 100
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
