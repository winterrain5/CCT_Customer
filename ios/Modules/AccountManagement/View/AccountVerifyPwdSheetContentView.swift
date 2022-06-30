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
  var type:SendVerificaitonCodeType = .EditPhone {
    didSet {
      contentView.setMessage(with: type)
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    contentView.confirmHandler = { [weak self] in
      guard let `self` = self else { return }
      self.dismiss(complete: {
        switch self.type {
        case .EditPassword:
          let vc = ChangePwdController(type: .Change)
          UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
        case .DeleteAccount:
          self.deleteAccount()
        default:
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
  
  func deleteAccount() {
    let params = SOAPParams(action: .User, path: .delete)
    params.set(key: "userId", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
    
    let logData = SOAPDictionary()
    logData.set(key: "ip", value: "")
    logData.set(key: "create_uid", value: Defaults.shared.get(for: .clientId) ?? "")
    
    params.set(key: "logData", value: logData.result, type: .map(2))
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      let attr = NSMutableAttributedString(string: "Your account has been successfully deleted")
      AlertView.show(message: attr, messageAlignment: .left) {
        Defaults.shared.removeAll()
        let vc = LoginViewController()
        let nav = BaseNavigationController(rootViewController: vc)
        UIApplication.shared.keyWindow?.rootViewController = nav
      }
     
    } errorHandler: { e in
      Toast.dismiss()
    }

    
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
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var pwdTf: UITextField!
  var confirmHandler:(()->())?
  var cancelHandler:(()->())?
  var forgetPwdHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    pwdTf.delegate = self
  }
  
  func setMessage(with type:SendVerificaitonCodeType) {
    if type == .DeleteAccount {
      messageLabel.text = "You are deleting your account, please verify by entering your password."
    }else {
      messageLabel.text = "Before making changes, please verify by entering your password"
    }
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
