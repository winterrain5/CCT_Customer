//
//  QuestionSegmentSectionView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/24.
//

import UIKit

class QuestionSegmentSectionView: UIView,TTGTextTagCollectionViewDelegate {

  private lazy var tagView = TTGTextTagCollectionView().then { view in
    view.delegate = self
    view.scrollDirection = .horizontal
    view.showsHorizontalScrollIndicator = false
  }
  private var bottomLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:18)
    label.text = "Top Asked Questions"
  }
  private var selectedIndex:UInt = 0
  
  var tags:[QuestionSubjectModel] = [] {
    didSet {
      tags.forEach { [weak self] model in
        self?.addTags(model.subject ?? "")
      }
      tagView.updateTag(at: 0, selected: true)
      tagView.reload()
    }
  }
  
  var segmentDidClickHandler:((QuestionSubjectModel)->())?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addSubview(tagView)
    self.addSubview(bottomLabel)
    backgroundColor = .white
   
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func addTags(_ text:String) {
    let content = TTGTextTagStringContent(text: text, textFont: UIFont(name:.AvenirNextRegular,size:14), textColor: R.color.black333())
    let style = TTGTextTagStyle()
    style.backgroundColor = R.color.placeholder()!
    style.cornerRadius = 13
    style.exactHeight = 36
    style.extraSpace = .zero
    style.minWidth = 60
    style.extraSpace = CGSize(width: 20, height: 0)
    style.borderWidth = 0
    style.shadowColor = .clear
    
    let selectContent = TTGTextTagStringContent(text: text, textFont: UIFont(name: .AvenirNextDemiBold, size:14), textColor: .white)
    let selectedStyle = style.copy() as! TTGTextTagStyle
    selectedStyle.backgroundColor = UIColor(hexString: "#C44729")!
    
    let tag = TTGTextTag(content: content, style: style, selectedContent: selectContent, selectedStyle: selectedStyle)
    tagView.addTag(tag)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    tagView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.top.equalToSuperview().offset(10)
      make.height.equalTo(40)
    }
    
    bottomLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.bottom.equalToSuperview().inset(10)
      make.height.equalTo(28)
    }
    
  }
  
  func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
    tagView.updateTag(at: selectedIndex, selected: false)
    tagView.updateTag(at: index, selected: true)
    selectedIndex = index
    
    segmentDidClickHandler?(tags[Int(index)])
  }
}
