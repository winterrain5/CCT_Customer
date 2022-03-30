//
//  BlogSegmentSectionView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import UIKit

class BlogSegmentSectionView: UIView,TTGTextTagCollectionViewDelegate {

  private lazy var tagView = TTGTextTagCollectionView().then { view in
    view.delegate = self
    view.scrollDirection = .horizontal
    view.showsHorizontalScrollIndicator = false
  }
  private var selectedIndex:UInt = 0
  
  var tags:[BlogCategoryModel] = [] {
    didSet {
      tags.forEach { [weak self] model in
        self?.addTags(model.key_word ?? "")
      }
      tagView.updateTag(at: 0, selected: true)
      tagView.reload()
    }
  }
  
  var segmentDidClickHandler:((BlogCategoryModel)->())?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addSubview(tagView)
    backgroundColor = .white
   
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func addTags(_ text:String) {
    let content = TTGTextTagStringContent(text: text, textFont: UIFont(.AvenirNextRegular,14), textColor: R.color.black333())
    let style = TTGTextTagStyle()
    style.backgroundColor = R.color.placeholder()!
    style.cornerRadius = 13
    style.exactHeight = 36
    style.minWidth = 60
    style.extraSpace = CGSize(width: 20, height: 0)
    style.borderWidth = 0
    style.shadowColor = .clear
    
    let selectContent = TTGTextTagStringContent(text: text, textFont: UIFont(.AvenirNextDemiBold,14), textColor: .white)
    let selectedStyle = style.copy() as! TTGTextTagStyle
    selectedStyle.backgroundColor = UIColor(hexString: "#C44729")!
    
    let tag = TTGTextTag(content: content, style: style, selectedContent: selectContent, selectedStyle: selectedStyle)
    tagView.addTag(tag)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    tagView.snp.makeConstraints { make in
      make.edges.equalTo(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
    }
  }
  
  func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
    tagView.updateTag(at: selectedIndex, selected: false)
    tagView.updateTag(at: index, selected: true)
    selectedIndex = index
    
    segmentDidClickHandler?(tags[Int(index)])
  }
}
