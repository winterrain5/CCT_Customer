//
//  InputAccountContainer.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/7.
//

import UIKit
import TextFieldEffects
class InputAccountContainer: UIView,UITextFieldDelegate {
  @IBOutlet weak var nextButon: UIButton!
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
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    infoContentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    
  }
  
  @IBAction func nextAction(_ sender: Any) {
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
        pwdError2Label.text = isPwdConfirmValidate ? "" : "・The two passwords must be the same"
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
