//
//  AlertView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class AlertView: UIView {

  private var titleLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:18)
    label.textAlignment = .center
    label.numberOfLines = 2
    label.lineHeight = 28
  }
  private var messageLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name:.AvenirNextRegular,size:16)
    label.numberOfLines = 0
    label.lineHeight = 24
  }
  private var leftButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = UIColor(hexString: "e0e0e0")
    btn.titleColorForNormal = R.color.black333()
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.titleForNormal = "Cancel"
  }
  private var rightButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.titleForNormal = "Confirm"
  }
  private var messageAlignment:NSTextAlignment = .left {
    didSet {
      messageLabel.textAlignment = messageAlignment
    }
  }
  private var leftHandler:(()->())?
  private var rightHandler:(()->())?
  private var dismissHandler:(()->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)
    addSubview(messageLabel)
    addSubview(leftButton)
    addSubview(rightButton)
    
    backgroundColor = .white
    leftButton.addTarget(self, action: #selector(leftButtonAction), for: .touchUpInside)
    rightButton.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
    
    EntryKit.dismissHandler = {
      self.dismissHandler?()
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalToSuperview().offset(32)
    }
    messageLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.left.right.equalToSuperview().inset(24)
    }
    let buttonW = (kScreenWidth - 64 - 18) * 0.5
    leftButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(32)
      make.width.equalTo(buttonW)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(24 + kBottomsafeAreaMargin)
    }
    rightButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-32)
      make.width.equalTo(buttonW)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(24 + kBottomsafeAreaMargin)
    }
  }
  
  @objc func leftButtonAction() {
    EntryKit.dismiss {
      self.leftHandler?()
      self.dismissHandler?()
    }
  }
  @objc func rightButtonAction() {
    EntryKit.dismiss {
      self.rightHandler?()
      self.dismissHandler?()
    }
  }
  
  func config(with title:String,message:String,leftButtonTitle:String,rightButtonTitle:String) {
    titleLabel.text = title
    messageLabel.text = message
    leftButton.titleForNormal = leftButtonTitle
    rightButton.titleForNormal = rightButtonTitle
  }
  
  func config(with title:String,message:String) {
    leftButton.isHidden = true
    rightButton.isHidden = true
    config(with: title, message: message, leftButtonTitle: "", rightButtonTitle: "")
  }
  
  func config(with message:String) {
    leftButton.isHidden = true
    rightButton.isHidden = true
    config(with: "", message: message, leftButtonTitle: "", rightButtonTitle: "")
  }
  
  func config(with message:NSMutableAttributedString) {
    leftButton.isHidden = true
    rightButton.isHidden = true
    titleLabel.text = ""
    messageLabel.attributedText = message
    leftButton.titleForNormal = ""
    rightButton.titleForNormal = ""
  }
  
  func config(with title:String,message:NSMutableAttributedString,leftButtonTitle:String,rightButtonTitle:String) {
    leftButton.isHidden = false
    rightButton.isHidden = false
    titleLabel.text = title
    messageLabel.attributedText = message
    leftButton.titleForNormal = leftButtonTitle
    rightButton.titleForNormal = rightButtonTitle
  }
  
  static func show(title:String,
                   message:String = "",
                   leftButtonTitle:String = "Cancel",
                   rightButtonTitle:String = "Confirm",
                   messageAlignment:NSTextAlignment = .left,
                   leftHandler:(()->())? = nil,
                   rightHandler:(()->())? = nil,
                   dismissHandler:(()->())? = nil) {
    let view = AlertView()
    view.config(with: title, message: message,leftButtonTitle: leftButtonTitle,rightButtonTitle: rightButtonTitle)
    view.leftHandler = leftHandler
    view.rightHandler = rightHandler
    view.dismissHandler = dismissHandler
    view.messageAlignment = messageAlignment
    let titleHeight = title.heightWithConstrainedWidth(width: kScreenWidth - 48, font: UIFont(name: .AvenirNextDemiBold, size:18))
    let messageHeight = view.messageLabel.sizeThatFits(CGSize(width: kScreenWidth - 48, height: .infinity)).height
    
    let extraHeight = 170.cgFloat + kBottomsafeAreaMargin
    let totalHeight = titleHeight + messageHeight + extraHeight
    let size = CGSize(width: kScreenWidth, height: totalHeight)
    EntryKit.display(view: view, size: size, style: .sheet, backgroundColor: R.color.blackAlpha8()!, touchDismiss: true)
  }
  
  static func show(title:String,message:String,messageAlignment:NSTextAlignment = .left,dismissHandler:(()->())? = nil) {
    let view = AlertView()
    view.config(with: title, message: message)
    view.dismissHandler = dismissHandler
    view.messageAlignment = messageAlignment
    let titleHeight = title.heightWithConstrainedWidth(width: kScreenWidth - 48, font: UIFont(name: .AvenirNextDemiBold, size:18))
    let messageHeight = view.messageLabel.sizeThatFits(CGSize(width: kScreenWidth - 48, height: .infinity)).height
     
    let extraHeight = kBottomsafeAreaMargin + 80
    let totalHeight = titleHeight + messageHeight + extraHeight
    let size = CGSize(width: kScreenWidth, height: totalHeight)
    EntryKit.display(view: view, size: size, style: .sheet, backgroundColor: R.color.blackAlpha8()!, touchDismiss: true)
  }
  
  static func show(message:String,messageAlignment:NSTextAlignment = .left,dismissHandler:(()->())? = nil) {
    let view = AlertView()
    view.config(with: message)
    view.dismissHandler = dismissHandler
    view.messageAlignment = messageAlignment
    let messageHeight = view.messageLabel.sizeThatFits(CGSize(width: kScreenWidth - 48, height: .infinity)).height
    let extraHeight = kBottomsafeAreaMargin + 80
    let totalHeight = messageHeight + extraHeight
    let size = CGSize(width: kScreenWidth, height: totalHeight)
    EntryKit.display(view: view, size: size, style: .sheet, backgroundColor: R.color.blackAlpha8()!, touchDismiss: true)
  }
  
  static func show(title:String,
                   message:NSMutableAttributedString ,
                   leftButtonTitle:String,
                   rightButtonTitle:String,
                   messageAlignment:NSTextAlignment,
                   leftHandler:(()->())? = nil,
                   rightHandler:(()->())? = nil,
                   dismissHandler:(()->())? = nil) {
    let view = AlertView()
    view.config(with: title, message: message,leftButtonTitle: leftButtonTitle,rightButtonTitle: rightButtonTitle)
    view.leftHandler = leftHandler
    view.rightHandler = rightHandler
    view.dismissHandler = dismissHandler
    view.messageAlignment = messageAlignment
    let titleHeight = title.heightWithConstrainedWidth(width: kScreenWidth - 48, font: UIFont(name: .AvenirNextDemiBold, size:18))
    let messageHeight = view.messageLabel.sizeThatFits(CGSize(width: kScreenWidth - 48, height: .infinity)).height
    
    let extraHeight = 170.cgFloat + kBottomsafeAreaMargin
    let totalHeight = titleHeight + messageHeight + extraHeight
    let size = CGSize(width: kScreenWidth, height: totalHeight)
    EntryKit.display(view: view, size: size, style: .sheet, backgroundColor: R.color.blackAlpha8()!, touchDismiss: true)
  }
  
  
  
  static func show(message:NSMutableAttributedString,messageAlignment:NSTextAlignment = .left,dismissHandler:(()->())? = nil) {
    let view = AlertView()
    view.config(with: message)
    view.dismissHandler = dismissHandler
    view.messageAlignment = messageAlignment
    let messageHeight = view.messageLabel.sizeThatFits(CGSize(width: kScreenWidth - 48, height: .infinity)).height
    let extraHeight = kBottomsafeAreaMargin + 80
    let totalHeight = messageHeight + extraHeight
    let size = CGSize(width: kScreenWidth, height: totalHeight)
    EntryKit.display(view: view, size: size, style: .sheet, backgroundColor: R.color.blackAlpha8()!, touchDismiss: true)
  }
}
