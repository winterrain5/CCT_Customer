//
//  OnBoardCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/21.
//

import UIKit

struct OnBoardModel {
  var title:String
  var image:UIImage?
  var desc:String
}

class OnBoardCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  var model:OnBoardModel! {
    didSet {
      imageView.image = model.image
      titleLabel.text = model.title
      descLabel.text = model.desc
    }
  }
  override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
