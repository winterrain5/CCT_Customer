//
//  QuestionFlexibleCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/24.
//

import UIKit

class QuestionFlexibleCell: UITableViewCell {
  var borderView = UIView().then { view in
    view.cornerRadius = 16
    view.backgroundColor = .white
    view.borderWidth = 1
    view.borderColor = UIColor(hexString: "#E0E0E0")
  }
  var questionLabel = UILabel().then { label in
    label.font = UIFont(name: .AvenirNextDemiBold, size:18)
    label.textColor = R.color.black333()
    label.numberOfLines = 0
  }
  var answerLabel = UILabel().then { label in
    label.font = UIFont(name:.AvenirNextRegular,size:16)
    label.textColor = R.color.black333()
    label.numberOfLines = 0
  }
  var expendButton = UIButton()
  var expendHandler:((QuestionAnswerModel,Int)->())?
  
  var indexRow:Int = 0
  var cellHeight:CGFloat = 0
  var model:QuestionAnswerModel! {
    didSet {
      questionLabel.text = model.title
      answerLabel.text = model.content
      answerLabel.isHidden = !model.isExpend!
    }
  }
 
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(borderView)
    borderView.addSubview(questionLabel)
    borderView.addSubview(answerLabel)
    contentView.addSubview(expendButton)
    expendButton.addTarget(self, action: #selector(expendButtonAction(_:)), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    borderView.snp.makeConstraints { make in
      make.edges.equalTo(UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16))
    }
    expendButton.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    questionLabel.frame = CGRect(x: 16, y: 16, width: kScreenWidth - 64, height: 0)
    questionLabel.sizeToFit()
    
    answerLabel.frame = CGRect(x: 16, y: questionLabel.frame.maxY + 16, width: kScreenWidth - 64, height: 0)
    answerLabel.sizeToFit()
  }
  
  @objc func expendButtonAction(_ sender: Any) {
    model.isExpend?.toggle()
    let expendHeight = questionLabel.requiredHeight + answerLabel.requiredHeight + 58
    let notExpendHeight = questionLabel.requiredHeight + 46
    let cellHeight = (model?.isExpend)! ? expendHeight : notExpendHeight
    model.cellHeight = cellHeight
    self.expendHandler?(model,indexRow)
  }
  
}
