//
//  WalletAddUserHeadView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/9.
//

import UIKit

class WalletAddUserHeadView: UIView,UITextFieldDelegate {

  @IBOutlet weak var tf: UITextField!
  @IBOutlet weak var tfContentView: UIView!
  var endEditHandler:((String)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    tf.delegate = self
    tf.returnKeyType = .search
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    tfContentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    self.endEditHandler?(textField.text ?? "")
    return true
  }
  
//  func textFieldDidBeginEditing(_ textField: UITextField) {
//    self.endEditHandler?(textField.text ?? "")
//  }
}
