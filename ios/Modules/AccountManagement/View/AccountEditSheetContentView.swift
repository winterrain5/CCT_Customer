//
//  AccountEditSheetContentView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit
import IQKeyboardManagerSwift

class AccountEditSheetView: UIView {
  var contentView = AccountEditSheetContentView.loadViewFromNib()
  let contentHeight:CGFloat = 280
  var scrolview = UIScrollView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 20
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    contentView.confirmHandler = { [weak self] text in
      guard let `self` = self else { return }
      if self.contentView.type == .EditEmail {
        self.checkUserEmailExists(text)
      }else {
        self.checkUserMobileExists(text)
      }
    }
    contentView.cancelHandler = { [weak self] in
      self?.dismiss()
    }
    
    scrolview.contentSize = CGSize(width: kScreenWidth, height: contentHeight)
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    scrolview.addGestureRecognizer(tap)
  }
  
  func checkUserMobileExists(_ text:String) {
    if text.isEmpty {
      Toast.showError(withStatus: "Mobile is empty")
      return
    }
    let params = SOAPParams(action: .Client, path: .userMobileExists)
    params.set(key: "mobile", value: text)
    
    NetworkManager().request(params: params) { data in
      self.dismiss()
      self.navigateToSendCode(text)
    } errorHandler: { e in
      if e.errorInfo().message.isEmpty {
        Toast.showError(withStatus: "Mobile is exists")
      }
    }

  }
  
  func checkUserEmailExists(_ text:String) {
    if text.isEmpty {
      Toast.showError(withStatus: "Email is empty")
      return
    }
    let params = SOAPParams(action: .Client, path: .userEmailExists)
    params.set(key: "email", value: text)
    
    NetworkManager().request(params: params) { data in
      
      if (JSON.init(from: data)?.stringValue ?? "") == "1" {
        Toast.showError(withStatus: "Email is exists")
      }else {
        self.dismiss()
        self.navigateToSendCode(text)
      }
      
    } errorHandler: { e in
      if e.errorInfo().message.isEmpty {
        Toast.showError(withStatus: "Email is exists")
      }
    }
  }
  
  func navigateToSendCode(_ source:String) {
    let vc = VerificationCodeController(type: self.contentView.type,source: source)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
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
    contentView.size = CGSize(width: kScreenWidth, height: contentHeight)
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  
  static func show(fromView:UIView,type:SendVerificaitonCodeType) {
    
    let view = AccountEditSheetView()
    view.frame = fromView.bounds
    view.contentView.type = type
    
    fromView.addSubview(view)
    view.show()
    
  }

  
}

class AccountEditSheetContentView: UIView,UITextFieldDelegate {

   
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!
  @IBOutlet weak var tf: UITextField!
  var confirmHandler:((String)->())?
  var cancelHandler:(()->())?
  var type:SendVerificaitonCodeType = .EditPhone {
    didSet {
      
      if type == .EditPhone {
        titleLabel.text = "Edit phone number"
        typeLabel.text = "Phone Number"
        tf.placeholder = "Phone Number"
        tf.keyboardType = .phonePad
      }else {
        titleLabel.text = "Edit email"
        typeLabel.text = "Email"
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    tf.delegate = self
    
  }
    
  
  @IBAction func cancelAction(_ sender: Any) {
    cancelHandler?()
  }
  
  @IBAction func confirmAction(_ sender: Any) {
    confirmHandler?(tf.text ?? "")
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  
  
}
