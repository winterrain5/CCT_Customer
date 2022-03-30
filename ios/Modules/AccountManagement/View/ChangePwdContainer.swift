//
//  ChangePwdContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/23.
//

import UIKit
enum EditPwdType {
  case Change
  case Reset
}
class ChangePwdContainer: UIView,UITextFieldDelegate {
  
  var type:EditPwdType = .Change {
    didSet {
      if type == .Change {
        titleLabel.text = "Change Password"
        pwd1Tf.placeholder = "Enter Password"
        pwd2Tf.placeholder = "Re-Password"
      }else {
        titleLabel.text = "Reset Password"
        pwd1Tf.placeholder = "Enter New Password"
        pwd2Tf.placeholder = "Re-Enter New Password"
      }
    }
  }
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var pwd1Tf: UITextField!
  @IBOutlet weak var pwd2Tf: UITextField!
  
  @IBOutlet weak var confirmButton: LoadingButton!
  var confirmHandler:((String)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    
    pwd1Tf.delegate = self
    
    pwd2Tf.delegate = self
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  @IBAction func confirmButtonAction(_ sender: Any) {
    let text = pwd2Tf.text ?? ""
    if text.isEmpty { return }
    confirmHandler?(text)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  func textFieldDidEndEditing(_ textField: UITextField) {
    let text = textField.text ?? ""
    
    if textField == pwd1Tf && !isPasswordRuler(password: text){
      Toast.showError(withStatus: "Password does not meet the rules")
    }
    if textField == pwd2Tf {
      if !isPasswordRuler(password: text) {
        Toast.showError(withStatus: "Password does not meet the rules")
        return
      }
      if pwd2Tf.text != pwd1Tf.text {
        Toast.showError(withStatus: "The password and confirmation password should be consistent")
        confirmButton.isEnabled = false
      }else {
        confirmButton.isEnabled = true
      }
    }
  }
  
  func isPasswordRuler(password:String) -> Bool {
    let passwordRule = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{6,}$"
    let regexPassword = NSPredicate(format: "SELF MATCHES %@",passwordRule)
    if regexPassword.evaluate(with: password) == true {
      return true
    }else
    {
      return false
    }
  }
  
}
