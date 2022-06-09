//
//  AccountVerifyPwdSheetContentView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit
import IQKeyboardManagerSwift
class AccountVerifyPwdSheetView: UIView {
  var contentView = AccountVerifyPwdSheetContentView.loadViewFromNib()
  let contentHeight:CGFloat = 420
  var scrolview = UIScrollView()
  var type:SendVerificaitonCodeType = .EditPhone
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    contentView.confirmHandler = { [weak self] in
      guard let `self` = self else { return }
      self.dismiss(complete: {
        if self.type == .EditPassword {
          let vc = ChangePwdController(type: .Change)
          UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
        }else {
          AccountEditSheetView.show(fromView:( UIViewController.getTopVc()?.view)!, type: self.type)
        }
        
      })
    }
    contentView.cancelHandler = { [weak self] in
      self?.dismiss()
    }
    contentView.forgetPwdHandler = { [weak self] in
      self?.dismiss(complete: {
        let vc = ForgetPwdController()
        UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
      })
    }

    scrolview.contentSize = CGSize(width: kScreenWidth, height: contentHeight)
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    scrolview.addGestureRecognizer(tap)
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
  
  func dismiss(complete: (()->())? = nil) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.contentView.frame.origin.y = kScreenHeight
      self.backgroundColor = .clear
    } completion: { flag in
      complete?()
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
    
    let view = AccountVerifyPwdSheetView()
    view.frame = fromView.bounds
    view.type = type
    
    fromView.addSubview(view)
    view.show()
    
  }
  
  
}

class AccountVerifyPwdSheetContentView: UIView,UITextFieldDelegate {
  @IBOutlet weak var pwdTf: UITextField!
  var confirmHandler:(()->())?
  var cancelHandler:(()->())?
  var forgetPwdHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    pwdTf.delegate = self
  }
  
  @IBAction func forgetPwdButtonAction(_ sender: Any) {
    forgetPwdHandler?()
  }
  @IBAction func cancelAction(_ sender: Any) {
    cancelHandler?()
  }
  
  @IBAction func confirmAction(_ sender: Any) {
    if confirmPwd() {
      confirmHandler?()
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  
  func confirmPwd() -> Bool {
    let  loginPwd = Defaults.shared.get(for: .loginPwd) ?? ""
    if loginPwd.isEmpty {
      Toast.showMessage("password is not saved by login")
      return false
    }
    
    let text = pwdTf.text ?? ""
    if text.isEmpty { return false }
    if text != loginPwd {
      Toast.showMessage("The password is incorrect")
      return false
    }
    
    return true
  }
}
