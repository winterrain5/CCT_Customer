//
//  BlogCreateBoardSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import UIKit
import IQKeyboardManagerSwift
class BlogCreateBoardSheetContentView: UIView,UITextFieldDelegate {

  @IBOutlet var boardNameTf: UITextField!
  var addBoardHandler:((String)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    boardNameTf.returnKeyType = .done
    boardNameTf.clearButtonMode = .whileEditing
    boardNameTf.delegate = self
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func addBoardButtonAction(_ sender: LoadingButton) {
    if boardNameTf.text?.isEmpty ?? true{
      Toast.showMessage("board name can not be empty")
      return
    }
    addBoardHandler?(boardNameTf.text!)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
}
