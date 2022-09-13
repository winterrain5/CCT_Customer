//
//  BlogItemCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import UIKit

class BlogItemCell: UITableViewCell {

  @IBOutlet weak var blogImageView: UIImageView!
  @IBOutlet weak var blogTitleLabel: UILabel!
  @IBOutlet weak var blogAutherLabel: UILabel!
  @IBOutlet weak var blogDateLabel: UILabel!
  @IBOutlet weak var tagView: TTGTextTagCollectionView!
  @IBOutlet weak var bookmarkButton: UIButton!
  @IBOutlet weak var shareButton: UIButton!
  
  var shareHandler:((BlogModel)->())?
  var bookmarkHandler:((BlogModel)->())?
  
  var shareHandler2:((BlogBookmarkedModel)->())?
  var bookmarkHandler2:((BlogBookmarkedModel)->())?
  
  var model:BlogModel! {
    didSet {
    
      blogImageView.yy_setImage(with: model.thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
      blogTitleLabel.text = model.title
      if model.has_booked {
        bookmarkButton.imageForNormal = R.image.blog_item_bookmark()
      }else {
        bookmarkButton.imageForNormal = R.image.blog_item_unbookmark()
      }
      if let changeTime = model.change_time {
        blogDateLabel.text = changeTime.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM")
      }else {
        blogDateLabel.text = model.create_time?.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM")
      }
      
      setAutherAttribute(model.location_name ?? "")
      
      self.tagView.removeAllTags()
      model.filters?.forEach({ [weak self] filter in
        guard let `self` = self else { return }
        self.addTags(filter.key_word ?? "")
      })
      self.tagView.reload()
    }
    
  }
  
  var bookmarkedModel:BlogBookmarkedModel! {
    didSet {
      
      blogImageView.yy_setImage(with: bookmarkedModel.thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
      blogTitleLabel.text = bookmarkedModel.title
      if bookmarkedModel.has_booked ?? false {
        bookmarkButton.imageForNormal = R.image.blog_item_bookmark()
      }else {
        bookmarkButton.imageForNormal = R.image.blog_item_unbookmark()
      }
      if let changeTime = bookmarkedModel.change_time {
        blogDateLabel.text = changeTime.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM")
      }else {
        blogDateLabel.text = bookmarkedModel.create_time?.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM")
      }
      setAutherAttribute(bookmarkedModel.location_name ?? "")
      
      self.tagView.removeAllTags()
      bookmarkedModel.filter_labels?.forEach({ [weak self] filter in
        guard let `self` = self else { return }
        self.addTags(filter.key_word ?? "")
      })
      
      self.tagView.reload()
    }
  }
  
  func setAutherAttribute(_ name:String) {
    let str = "by \(name)"
    let attr = NSMutableAttributedString(string: str)
    attr.addAttribute(.font, value: UIFont(name:.AvenirNextRegular,size:10), range: NSRange(location: 0, length: 2))
    attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size:13), range: NSRange(location: 2, length: str.count - 2))
    blogAutherLabel.attributedText = attr
  }
  

  override func awakeFromNib() {
    super.awakeFromNib()
    
    
    bookmarkButton.addTarget(self, action: #selector(bookmarkAction(_:)), for: .touchUpInside)
    shareButton.addTarget(self, action: #selector(shareButtonAction(_:)), for: .touchUpInside)
  }
  
  func addTags(_ text:String) {
    let content = TTGTextTagStringContent(text: text, textFont: UIFont(name:.AvenirNextRegular,size:12), textColor: UIColor(hexString: "333333"))
    let style = TTGTextTagStyle()
    style.backgroundColor = UIColor(hexString: "#FAF3EB")!
    style.cornerRadius = 13
    style.exactHeight = 26
    style.minWidth = 60
    style.extraSpace = CGSize(width: 20, height: 0)
    style.borderWidth = 0
    style.shadowColor = .clear
    let tag = TTGTextTag(content: content, style: style)
    tagView.addTag(tag)
  }
  
  @objc func shareButtonAction(_ sender: UIButton) {
    shareHandler?(model)
    shareHandler2?(bookmarkedModel)
  }
  
  @objc func bookmarkAction(_ sender: UIButton) {
    bookmarkHandler?(model)
    bookmarkHandler2?(bookmarkedModel)
  }
}
