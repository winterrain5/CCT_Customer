//
//  MyOrderHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class MyOrderHeaderView: UIView,TTGTextTagCollectionViewDelegate {

  private lazy var tagView = TTGTextTagCollectionView().then { view in
    view.delegate = self
    view.scrollDirection = .horizontal
    view.showsHorizontalScrollIndicator = false
  }
  private var selectedIndex:UInt = 0
  var statusDidClickHandler:((Int)->())?


  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(tagView)
    addTags("In Progress")
    addTags("Completed")
    addTags("Cancelled")
    
    tagView.updateTag(at: 0, selected: true)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    tagView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.top.equalToSuperview().offset(24)
      make.height.equalTo(40)
    }
  }
  
  func addTags(_ text:String) {
    let content = TTGTextTagStringContent(text: text, textFont: UIFont(name:.AvenirNextRegular,size:14), textColor: R.color.black333())
    let style = TTGTextTagStyle()
    style.backgroundColor = R.color.placeholder()!
    style.cornerRadius = 13
    style.exactHeight = 36
    style.minWidth = 60
    style.extraSpace = CGSize(width: 20, height: 0)
    style.borderWidth = 0
    style.shadowColor = .clear
    
    let selectContent = TTGTextTagStringContent(text: text, textFont: UIFont(name: .AvenirNextDemiBold, size:14), textColor: .white)
    let selectedStyle = style.copy() as! TTGTextTagStyle
    selectedStyle.backgroundColor = R.color.theamBlue()!
    
    let tag = TTGTextTag(content: content, style: style, selectedContent: selectContent, selectedStyle: selectedStyle)
    tagView.addTag(tag)
  }
 
  
  func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
    tagView.updateTag(at: selectedIndex, selected: false)
    tagView.updateTag(at: index, selected: true)
    selectedIndex = index
    
    statusDidClickHandler?(Int(index))
  }

}
