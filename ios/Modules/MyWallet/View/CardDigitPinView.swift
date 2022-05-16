//
//  CardDigitPinView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/15.
//

import UIKit
import IQKeyboardManagerSwift

@objcMembers
class CardDigitPinView: UIView {

  var contentView = CardDigitPinContentView()
  let contentHeight:CGFloat = 340
  var scrolview = UIScrollView()
  var confirmHandler:((String)->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    scrolview.contentSize = CGSize(width: kScreenWidth, height: contentHeight)
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    scrolview.addGestureRecognizer(tap)
    
    contentView.closeHandler = {
      [weak self] in
      self?.dismiss()
    }
    contentView.confirmHandler = {
      [weak self] pin in
      self?.confirmHandler?(pin)
      self?.dismiss()
    }
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  @objc func tapAction(_ ges:UIGestureRecognizer) {
    let location = ges.location(in: scrolview)
    if location.y < (kScreenHeight - contentHeight) {
     dismiss()
    }
  }
  
  func dismiss() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.contentView.frame.origin.y = kScreenHeight
      self.backgroundColor = .clear
    } completion: { flag in
      self.removeFromSuperview()
    }
  }
  
  func show() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
      self.contentView.frame.origin.y = kScreenHeight - self.contentHeight
    } completion: { flag in
      
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    scrolview.frame = self.bounds
    contentView.width = kScreenWidth
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  static func showView(pin:String, confirmHandler:@escaping ((String)->())) {
    let spView = UIViewController.getTopVc()?.view
    
    let view = CardDigitPinView()
    view.confirmHandler = confirmHandler
    view.contentView.pin = pin
    view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
   
    spView?.addSubview(view)
    
    view.show()
  }
}

enum CardDigitPinSetType {
  case config
  case validate
}

class CardDigitPinContentView: UIView {
  // 1 config 2 validate
  var type:CardDigitPinSetType = .config
  private var titleLabel = UILabel().then { label in
    label.text = "Please setup a 6 digit Pin"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextBold,24)
  }
  private var closeButton = UIButton().then { btn in
    btn.imageForNormal = R.image.card_set_pin_close()
    btn.contentHorizontalAlignment = .right
    btn.contentVerticalAlignment = .top
  }
  private var confirmButton = LoadingButton().then { btn in
    btn.titleForNormal = "Confirm"
    btn.backgroundColor = R.color.line()
    btn.cornerRadius = 22
    btn.titleLabel?.font = UIFont(.AvenirNextBold,14)
  }
  private var messageLabel = UILabel().then { label in
    label.text = "Pin will be use for verification purposes"
    label.textColor = UIColor(hexString: "979797")
    label.font = UIFont(.AvenirNextRegular,16)
  }
  private var inputBox:CRBoxInputView!
  
  var closeHandler:(()->())?
  var confirmHandler:((String)->())?
  private var finishCount:Int = 0
  var pin:String = "" {
    didSet {
      if !pin.isEmpty {
        self.type = .validate
        titleLabel.text = "Enter 6 digit Pin"
        messageLabel.text = "Pin is use for verification purposes"
      }else {
        self.type = .config
        titleLabel.text = "Please setup a 6 digit Pin"
        messageLabel.text = "Pin will be use for verification purposes"
      }
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
   
    addSubview(titleLabel)
    addSubview(messageLabel)
    addSubview(confirmButton)
    addSubview(closeButton)
    
    inputBox = CRBoxInputView(codeLength: 6)
    inputBox.inputType = .number
    inputBox.resetCodeLength(6, beginEdit: false)
    inputBox.ifNeedSecurity = true
    inputBox.securityDelay  = 0
    
    inputBox.boxFlowLayout?.minimumInteritemSpacing = 8
    inputBox.boxFlowLayout?.minimumLineSpacing = 8
    inputBox.boxFlowLayout?.itemSize = CGSize(width: floor((kScreenWidth - 48 - 50) / 6), height: 64)
    
    let property = CRBoxInputCellProperty()
    property.borderWidth = 1
    property.cellBorderColorNormal = UIColor(hexString: "e0e0e0")!
    property.cellBorderColorSelected = UIColor(hexString: "e0e0e0")!
    property.cornerRadius = 16
    property.securitySymbol = "*"
    property.cellFont = UIFont(.AvenirNextDemiBold,32)
    inputBox.customCellProperty = property
    inputBox.loadAndPrepare(withBeginEdit: false)
    inputBox.ifClearAllInBeginEditing = true
    addSubview(inputBox)
    
    inputBox.textDidChangeblock = { [weak self] text,isFinish in
      guard let `self` = self else { return }
      let value = text ?? ""
      if value.isEmpty { return }
      if self.type == .validate {
        if isFinish {
          if value.md5 != self.pin {
            self.notMatchMessageStyle()
          }else {
            self.confirmButton.isEnabled = true
            self.confirmButton.backgroundColor = R.color.theamBlue()
          }
        }
      }
      
      if self.type == .config {
        if isFinish {
          self.finishCount += 1
        }
        if isFinish && self.finishCount == 1 {
          self.pin = value.md5
          self.titleLabel.text = "Re-enter 6 digit Pin"
          self.normalMessageStyle()
          self.inputBox.clearAll(withBeginEdit: false)
        }
        if isFinish && self.finishCount == 2 {
          if value.md5 != self.pin {
            self.notMatchMessageStyle()
            self.finishCount = 1
          }else {
            self.confirmButton.isEnabled = true
            self.confirmButton.backgroundColor = R.color.theamBlue()
            self.finishCount = 0
          }
          
        }
      }
    }
    
    inputBox.textEditStatusChangeblock = { [weak self] status in
      self?.normalMessageStyle()
    }
   

    closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
    confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    confirmButton.isEnabled = false
    
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 80
    
    
  }
  
  func normalMessageStyle() {
    if type == .config {
      messageLabel.text = "Pin will be use for verification purposes"
    }else {
      messageLabel.text = "Pin is use for verification purposes"
    }
    self.messageLabel.textColor = UIColor(hexString: "979797")
    
  }
  
  func notMatchMessageStyle() {
    self.messageLabel.text = "Pins do not match. Please try again"
    self.messageLabel.textColor = R.color.theamRed()
    self.inputBox.shake()
    self.inputBox.clearAll(withBeginEdit: false)
  }
 
  @objc func confirmAction() {
    if type == .config {
      self.saveUserPayPd()
    }else {
      self.confirmHandler?(self.pin)
    }
    
  }
  
  func saveUserPayPd() {
    
    confirmButton.startAnimation()
    let params = SOAPParams(action: .Client, path: .saveTpd)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "pd", value: self.pin)
    NetworkManager().request(params: params) { data in
      self.confirmHandler?(self.pin)
      self.confirmButton.stopAnimation()
    } errorHandler: { e in
      self.confirmButton.stopAnimation()
      Toast.showError(withStatus: "Failed to save payment password")
    }

  }
  
  
  @objc func closeButtonAction() {
    closeHandler?()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(24)
      make.height.equalTo(36)
    }
    
    inputBox.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.height.equalTo(64)
      make.top.equalTo(titleLabel.snp.bottom).offset(24)
    }
    
    closeButton.snp.makeConstraints { make in
      make.top.right.equalToSuperview().inset(22)
      make.size.equalTo(CGSize(width: 30, height: 30))
    }
    
    messageLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(inputBox.snp.bottom).offset(16)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.width.equalTo(188)
      make.height.equalTo(44)
      make.centerX.equalToSuperview()
      make.top.equalTo(messageLabel.snp.bottom).offset(30)
    }
    
    
  }
}
