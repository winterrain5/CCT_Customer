//
//  ForgetPwdContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/23.
//

import UIKit

class ForgetPwdContainer: UIView,UITextFieldDelegate {

  @IBOutlet weak var emailTf: UITextField!
  @IBOutlet weak var confirmButton: LoadingButton!
  var confirmHandler:((String)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    
    emailTf.returnKeyType = .done
    emailTf.delegate = self
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func confirmButtonAction(_ sender: Any) {
    confirmHandler?(emailTf.text ?? "")
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
}
