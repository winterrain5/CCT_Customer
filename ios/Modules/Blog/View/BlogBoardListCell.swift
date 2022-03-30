//
//  BlogBookmarkCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/7.
//

import UIKit

class BlogBoardListCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  var model:BlogBoardModel! {
    didSet {
      imageView.yy_setImage(with: model.cover_img?.asURL, options: .setImageWithFadeAnimation)
      nameLabel.text = model.name
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
}
