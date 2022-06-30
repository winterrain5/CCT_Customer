//
//  EnterAccountContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/28.
//

import UIKit

class EnterAccountContainer: UIView,UITextFieldDelegate {

  @IBOutlet weak var registerBtn: LoadingButton!
  @IBOutlet weak var loginBtn: LoadingButton!
  @IBOutlet weak var pwdTf: UITextField!
  @IBOutlet weak var accountTf: UITextField!
  var otpCode = ""
  var isLoginByMobile = false
  var outlet:(id:String,name:String)?
  var isFromScanQRCode = false {
    didSet {
      registerBtn.isHidden = !isFromScanQRCode
    }
  }
  @IBOutlet weak var bottomView: UIView!
  override func awakeFromNib() {
    super.awakeFromNib()
    pwdTf.delegate = self
    pwdTf.returnKeyType = .done
    pwdTf.isSecureTextEntry  = true
    accountTf.delegate = self
    accountTf.returnKeyType = .next
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    bottomView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  @IBAction func registerNewAction(_ sender: Any) {
    
    let vc = InputPhoneController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
    
  }
  
  @IBAction func forgotPwdAction(_ sender: Any) {
    ForgetPwdSheetView.show()
  }
  @IBAction func loginAction(_ sender: Any) {
    
    let params = SOAPParams(action: .Query, path: .getQueryData,isNeedToast: false)
    params.set(key: "type", value: 1)
    params.set(key: "select", value: "u.id,u.password,u.mobile,u.email")
    params.set(key: "from", value: "t_user u")
    
    let dict = SOAPDictionary()
    if isLoginByMobile {
      dict.set(key: "u.mobile", value: accountTf.text?.trim() ?? "")
    }else {
      dict.set(key: "u.email", value: accountTf.text?.trim() ?? "")
    }
    
    dict.set(key: "u.is_delete", value: 0)
    
    params.set(key: "where", value: dict.result, type: .map(1))
    
    loginBtn.startAnimation()
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(UserPasswordModel.self, from: data),models.count > 0 ,let password = models.first,password.password == (self.pwdTf.text?.md5 ?? "") {
        self.getTClientByuserId(userID: password.id)
      }else {
        self.loginBtn.stopAnimation()
        AlertView.show(message: "The mobile / email / password is invalid. Please try again.")
      }
    } errorHandler: { e in
      self.loginBtn.stopAnimation()
      AlertView.show(message: "The mobile / email / password is invalid. Please try again.")
    }
  
  }
  
  func getTClientByuserId(userID:String) {
    let params = SOAPParams(action: .Client, path: .getTClientByUserId,isNeedToast: false)
    params.set(key: "userId", value: userID)
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserPasswordModel.self, from: data) {
        Defaults.shared.set(model.id, for: .clientId)
        Defaults.shared.set(self.pwdTf.text ?? "", for: .loginPwd)
        if self.isFromScanQRCode {
          self.loginBtn.stopAnimation()
          let vc = CheckInTodaySessionController(outlet: self.outlet)
          UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
        }else {
          if self.isLoginByMobile {
            self.sendSMSForMobile(userID: userID, clientID: model.id)
          }else {
            self.sendSmsForEmail(userID: userID, clientID: model.id)
          }
        }
        
      }else {
        AlertView.show(message: "The mobile / email / password is invalid. Please try again.")
      }
    } errorHandler: { e in
      self.loginBtn.stopAnimation()
      AlertView.show(message: "The mobile / email / password is invalid. Please try again.")
    }

  }
  
  func sendSMSForMobile(userID:String,clientID:String) {
    let mobile = accountTf.text?.trim() ?? ""
    let mapParams = SOAPParams(action: .Sms, path: .sendSmsForMobile)
    
    let params = SOAPDictionary()
    params.set(key: "title", value: "Sign in")
    params.set(key: "mobile", value: mobile)
    
    self.otpCode = Int.random(in: 1001...9999).string
    params.set(key: "message", value: "Your OTP is \(self.otpCode). Please enter the OTP within 2 minutes")
    params.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "client_id", value: clientID)
    
    mapParams.set(key: "params", value: params.result, type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      self.loginBtn.stopAnimation()
      let vc = VerificationCodeController(type: .LoginByMobile, source: mobile,otpCode:self.otpCode)
      UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
    } errorHandler: { e in
      self.loginBtn.stopAnimation()
    }

  }
  
  func sendSmsForEmail(userID:String,clientID:String) {
    let email = accountTf.text?.trim() ?? ""
    let mapParams = SOAPParams(action: .Sms, path: .sendSmsForEmail)
    
    let params = SOAPDictionary()
    params.set(key: "title", value: "[Chien Chi Tow] App login")
    params.set(key: "email", value: email)
    
    self.otpCode = Int.random(in: 1001...9999).string
    params.set(key: "message", value: "Your OTP is \(self.otpCode). Please enter the OTP within 2 minutes")
    params.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "from_email", value: Defaults.shared.get(for: .sendEmail) ?? "")
    params.set(key: "client_id", value: clientID)
    
    mapParams.set(key: "params", value: params.result, type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      self.loginBtn.stopAnimation()
      let vc = VerificationCodeController(type: .LoginByEmail, source: email,otpCode:self.otpCode)
      UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
    } errorHandler: { e in
      self.loginBtn.stopAnimation()
    }

  }
  

  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == accountTf {
      self.pwdTf.becomeFirstResponder()
    }else {
      self.endEditing(true)
    }

    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let account = accountTf.text ?? ""
    let pwd = pwdTf.text ?? ""
    if !account.isEmpty && !pwd.isEmpty {
      loginBtn.isEnabled = true
      loginBtn.backgroundColor = R.color.theamRed()
    }else {
      loginBtn.isEnabled = false
      loginBtn.backgroundColor = R.color.grayE0()
    }
    isLoginByMobile = !account.isValidEmail
    
  }
}
