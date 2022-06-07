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
  @IBOutlet weak var line1TopCons: NSLayoutConstraint!
  
  @IBOutlet weak var line2TopCons: NSLayoutConstraint!
  @IBOutlet weak var pwdErrorLabel: UILabel!
  @IBOutlet weak var emailErrorLabel: UILabel!
  @IBOutlet weak var pwdError2Label: UILabel!
  
  @IBOutlet weak var infoContentView: UIView!

  
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
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    let text = textField.text ?? ""
    if text.isEmpty { return }
    if textField == emailTf {
      emailErrorLabel.isHidden = text.isValidEmail
      emailErrorLabel.text = text.isValidEmail ? "" : "・Email entered is invalid"
    }
    
    if textField == pwTf {
      var errorMessage = ""
      if text.count < 6 {
        /// ・Passwords need to be at least 6 characters ・At least one lowercase character ・At lease one uppercase character ・Must have numerical number
        errorMessage += "・Passwords need to be at least 6 characters\n"
      }
      if text.hasNumbers {
        errorMessage += "・Must have numerical number\n"
      }
      if !text.isHasLowercaseCharacter() {
        errorMessage += "・At least one lowercase character \n"
      }
      if !text.isHasUppercaseCharacter() {
        errorMessage += "・At lease one uppercase character \n"
      }
      pwdErrorLabel.text = errorMessage.isEmpty ? "" : errorMessage
      pwdErrorLabel.isHidden = errorMessage.isEmpty
    }
    
    if textField == pw2Tf {
      // The two passwords must be the same
      let isValid = text == (pw2Tf.text ?? "")
      pwdErrorLabel.text = isValid ? "" : "・The two passwords must be the same"
      pwdError2Label.isHidden = isValid
    }
    
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
      self.layoutIfNeeded()
    } completion: { flag in
      
    }

  }
}
