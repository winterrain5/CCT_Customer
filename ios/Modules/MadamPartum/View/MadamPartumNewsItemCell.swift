//
//  MadamPartumNewsItemCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit

class MadamPartumNewsItemCell: UICollectionViewCell {

  @IBOutlet weak var blogImageView: UIImageView!
  @IBOutlet weak var blogTitleLabel: UILabel!
  @IBOutlet weak var blogTagLabel: UILabel!

  @IBOutlet weak var bookmarkButton: UIButton!
  @IBOutlet weak var shareButton: UIButton!
  
  @IBOutlet weak var shadowView: UIView!
  var shareHandler:((BlogModel)->())?
  var bookmarkHandler:((BlogModel)->())?
  
  
  var model:BlogModel! {
    didSet {
      blogImageView.yy_setImage(with: model.thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
      blogTitleLabel.text = model.title
      if model.has_booked {
        bookmarkButton.imageForNormal = R.image.blog_item_bookmark()
      }else {
        bookmarkButton.imageForNormal = R.image.blog_item_unbookmark()
      }
      blogTagLabel.text = model.filters?.reduce("", { $0 + "," + ($1.key_word ?? "")}).removingPrefix(",")
    }
    
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    bookmarkButton.addTarget(self, action: #selector(bookmarkAction(_:)), for: .touchUpInside)
    shareButton.addTarget(self, action: #selector(shareButtonAction(_:)), for: .touchUpInside)
  }
  
  @objc func shareButtonAction(_ sender: UIButton) {
    shareHandler?(model)
  }
  
  @objc func bookmarkAction(_ sender: UIButton) {
    bookmarkHandler?(model)
  }

  func addImageViewShadow() {
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.12)
    shadowView.addShadow(ofColor: light, radius: 4, offset: CGSize(width: 0, height: 2), opacity: 2)
  }
}
