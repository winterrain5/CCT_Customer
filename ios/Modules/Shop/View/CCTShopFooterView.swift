//
//  CCTShopFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/12.
//

import UIKit

class CCTShopFooterView: UICollectionReusableView,TTGTextTagCollectionViewDelegate {
        
  @IBOutlet weak var filterTagView: TTGTextTagCollectionView!
  @IBOutlet weak var searchView: ShopSearchView!
  var filterHandler:(()->())!
  var updateFilterHandler:((CCTShopFilterRequestModel)->())!
  var result:CCTShopFilterRequestModel! {
    didSet {
      Mirror(reflecting: CCTShopFilterRequestModel()).children.forEach { child in
        guard let key = child.label else { return }
        if key == "category" {
          let value = result.value(forKey: key) as! [ProductCategoryModel]
          value.forEach { e in
            addTags(e.name)
          }
        }
        if key == "orderBy" {
          let value = result.value(forKey: key) as! String
          if value == "ASC" {
            addTags("$ Low to Hight",120)
          }
          if value == "DESC" {
            addTags("$ Hight to Low",120)
          }
        }
        if key == "range" {
          let value = result.value(forKey: key) as! String
          if !value.isEmpty {
            addTags(value)
          }
        }
      }
    }
  }
  func addTags(_ text:String, _ exactWidth:CGFloat = 0) {
    let content = TTGTextTagStringContent(text: text, textFont: UIFont(.AvenirNextRegular,14), textColor: UIColor(hexString: "#bdbdbd")!)
    let style = TTGTextTagStyle()
    style.backgroundColor = .white
    style.cornerRadius = 14
    style.exactHeight = 28
    style.exactWidth = exactWidth
    style.minWidth = 60
    style.extraSpace = CGSize(width: 24, height: 0)
    style.borderWidth = 1
    style.borderColor = UIColor(hexString: "#bdbdbd")!
    style.shadowColor = .clear
  
    let tag = TTGTextTag(content: content, style: style)
    filterTagView.horizontalSpacing = 8
    filterTagView.scrollDirection = .horizontal
    filterTagView.contentInset = .zero
    filterTagView.addTag(tag)
  
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    filterTagView.delegate = self
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  @IBAction func filterButtonAction(_ sender: Any) {
    filterHandler()
  }
  
  func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
    filterTagView.removeTag(tag)
    let text = (tag.content as! TTGTextTagStringContent).text
    if text == "$ Low to Hight" || text == "$ Hight to Low"{
      result.orderBy = ""
    } else if text.contains(" - ") {
      result.price_low = ""
      result.price_high = ""
      result.range = ""
    } else {
      result.category.forEach { e in
        if e.name == text {
          result.category.removeAll(where: { $0.name == text })
        }
      }
    }
    
    updateFilterHandler(result)
  }
}
