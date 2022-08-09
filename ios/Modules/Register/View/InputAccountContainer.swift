//
//  InputAccountContainer.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/7.
//

import UIKit
import TextFieldEffects
import CryptoKit
class InputAccountContainer: UIView,UITextFieldDelegate {
  @IBOutlet weak var nextButon: LoadingButton!
  @IBOutlet weak var pw2Tf: HoshiTextField!
  @IBOutlet weak var pwTf: HoshiTextField!
  @IBOutlet weak var emailTf: HoshiTextField!
  @IBOutlet weak var pwdErrorLabel: UILabel!
  @IBOutlet weak var emailErrorLabel: UILabel!
  @IBOutlet weak var pwdError2Label: UILabel!
  
  @IBOutlet weak var infoContentView: UIView!
  
  var isEmaillValidate = false
  var isPwdValidate = false
  var isPwdConfirmValidate = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    emailErrorLabel.text = ""
    pwdErrorLabel.text = ""
    pwdError2Label.text = ""
    emailErrorLabel.isHidden = true
    pwdErrorLabel.isHidden = true
    pwdError2Label.isHidden = true
    
    emailTf.delegate = self
    pwTf.delegate = self
    pw2Tf.delegate = self
    
    if let user = Defaults.shared.get(for: .userModel) {
      emailTf.text = user.email
      isEmaillValidate = true
    }
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    infoContentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    
  }
  
  @IBAction func nextAction(_ sender: Any) {
    
    if let user = Defaults.shared.get(for: .userModel),!user.email.isEmpty,user.email == (emailTf.text ?? "") {
      next()
    }else {
      checkUserEmailExist()
    }
    
  }
  
  func checkUserEmailExist() {
    
    nextButon.startAnimation()
    
    let params = SOAPParams(action: .Client, path: .userEmailExists)
    params.set(key: "email", value: emailTf.text ?? "")
    
    NetworkManager().request(params: params) { data in
      self.nextButon.stopAnimation()
      let data = String(data: data, encoding: .utf8)
      if data == "0" {
        self.next()
      }else {
        AlertView.show(message: "Email already exists in the system, please confirm first.")
      }
    } errorHandler: { e in
      self.nextButon.stopAnimation()
    }

  }
  
  func next() {
    
    if let registInfo = Defaults.shared.get(for: .registModel) {
      registInfo.email = emailTf.text ?? ""
      registInfo.password = pwTf.text ?? ""
      Defaults.shared.set(registInfo, for: .registModel)
    }
    nextButon.stopAnimation()
    let vc = InputGeneralInfoController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
  }
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    validateText(textField)
    return true
  }
  
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
   
    validateText(textField)
  }
  
  func validateText(_ textField:UITextField) {
    
    let text = textField.text ?? ""
    if textField == emailTf {
      isEmaillValidate = text.isValidEmail && !text.isEmpty
      emailErrorLabel.isHidden = isEmaillValidate
      emailErrorLabel.text = isEmaillValidate ? "" : "・Email entered is invalid"
    }
    
    if textField == pwTf {
      var errorMessage = ""
      if text.count < 6 {
        /// ・Passwords need to be at least 6 characters ・At least one lowercase character ・At lease one uppercase character ・Must have numerical number
        errorMessage += "・Passwords need to be at least 6 characters\n"
      }
      if !text.isHasLowercaseCharacter() {
        errorMessage += "・At least one lowercase character \n"
      }
      if !text.isHasUppercaseCharacter() {
        errorMessage += "・At lease one uppercase character \n"
      }
      if !text.hasNumbers {
        errorMessage += "・Must have numerical number\n"
      }
      if text.isHasSpecialSymbol() {
        errorMessage += "・Password cannot contain special characters such as \"#@!~%^&*\"\n"
      }
      
      if text.isEmpty {
        errorMessage = ""
      }
      errorMessage = errorMessage.removingSuffix("\n")
      isPwdValidate = text.isPasswordRuler()
      pwdErrorLabel.text = errorMessage.isEmpty ? "" : errorMessage
      pwdErrorLabel.isHidden = errorMessage.isEmpty
    }
    
    if textField == pw2Tf {
      // The two passwords must be the same
      if !(pwTf.text?.isEmpty ?? false) {
        isPwdConfirmValidate = (text == (pwTf.text ?? ""))
        pwdError2Label.text = isPwdConfirmValidate ? "" : "・Password is inconsistent with Re-enter Password"
        pwdError2Label.isHidden = isPwdConfirmValidate
      }
     
    }
    
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
      self.layoutIfNeeded()
    } completion: { flag in
      
    }
    
    if isEmaillValidate && isPwdValidate && isPwdConfirmValidate {
      nextButon.isEnabled = true
      nextButon.backgroundColor = R.color.theamRed()
    }else {
      nextButon.isEnabled = false
      nextButon.backgroundColor = R.color.grayE0()
    }
  }
}
