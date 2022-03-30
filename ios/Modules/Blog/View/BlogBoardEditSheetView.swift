//
//  BlogBoardEditSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/10.
//

import UIKit

class BlogBoardEditSheetView: UIView,UITextFieldDelegate {

  @IBOutlet var boardNameTf: UITextField!
  var confirmHandler:((String)->())?
  var deleteHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    boardNameTf.returnKeyType = .done
    boardNameTf.clearButtonMode = .whileEditing
    
    boardNameTf.delegate = self
  }
  
  static func show(with originalName:String, confirmHandler:@escaping (String)->(), deleteHandler:@escaping ()->()) {
    let view = BlogBoardEditSheetView.loadViewFromNib()
    view.boardNameTf.text = originalName
    view.deleteHandler = deleteHandler
    view.confirmHandler = confirmHandler
    let size = CGSize(width: kScreenWidth, height: 295 + kBottomsafeAreaMargin)
    EntryKit.display(view: view, size: size, style: EntryStyle.sheet, backgroundColor: R.color.blackAlpha8()!, touchDismiss: true)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  @IBAction func deleteButtonAction(_ sender: Any) {
    EntryKit.dismiss {
      self.deleteHandler?()
    }
  }

  @IBAction func confirmButtonAction(_ sender: Any) {
    EntryKit.dismiss {
      if self.boardNameTf.text?.isEmpty ?? true{
        Toast.showMessage("board name can not be empty")
        return
      }
      self.confirmHandler?(self.boardNameTf.text!)
    }
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }

}
