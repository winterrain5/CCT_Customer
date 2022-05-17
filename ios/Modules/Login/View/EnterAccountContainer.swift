//
//  EnterAccountContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/28.
//

import UIKit

class EnterAccountContainer: UIView,UITextFieldDelegate {

  @IBOutlet weak var loginBtn: LoadingButton!
  @IBOutlet weak var pwdTf: UITextField!
  @IBOutlet weak var accountTf: UITextField!
  var otpCode = ""
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

  @IBAction func forgotPwdAction(_ sender: Any) {
    
  }
  @IBAction func loginAction(_ sender: Any) {
    
    let params = SOAPParams(action: .Query, path: .getQueryData)
    params.set(key: "type", value: 1)
    params.set(key: "select", value: "u.id,u.password,u.mobile,u.email")
    params.set(key: "from", value: "t_user u")
    
    let dict = SOAPDictionary()
    dict.set(key: "u.mobile", value: accountTf.text?.trim() ?? "")
    dict.set(key: "u.is_delete", value: 0)
    
    params.set(key: "where", value: dict.result, type: .map(1))
    
    loginBtn.startAnimation()
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(UserPasswordModel.self, from: data),models.count > 0 ,let password = models.first,password.password == (self.pwdTf.text?.md5 ?? "") {
        self.sendSMSForMobile(userID: password.id)
      }
    } errorHandler: { e in
      self.loginBtn.stopAnimation()
    }

  }
  
  func sendSMSForMobile(userID:String) {
    let mobile = accountTf.text?.trim() ?? ""
    let mapParams = SOAPParams(action: .Sms, path: .sendSmsForMobile)
    
    let params = SOAPDictionary()
    params.set(key: "title", value: "Sign up")
    params.set(key: "mobile", value: mobile)
    
    self.otpCode = Int.random(in: 1001...9999).string
    params.set(key: "message", value: "Your OTP is \(self.otpCode). Please enter the OTP within 2 minutes")
    params.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    
    mapParams.set(key: "params", value: params.result, type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      self.loginBtn.stopAnimation()
      Defaults.shared.set(userID, for: .userId)
      let vc = VerificationCodeController(type: .Login, source: mobile,otpCode:self.otpCode)
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
    
  }
}
