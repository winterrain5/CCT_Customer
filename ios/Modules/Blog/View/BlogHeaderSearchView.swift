//
//  BlogHeaderSearchView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import UIKit

class BlogHeaderSearchView: UICollectionReusableView,UITextFieldDelegate {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var serchTF: UITextField!
  @IBOutlet weak var editButton: UIButton!
  var searchHandler:((String)->())?
  var editHandler:(()->())?
  var title:String = "" {
    didSet {
      titleLabel.text = title
    }
  }
  var placeholder:String = "" {
    didSet {
      serchTF.placeholder = placeholder
    }
  }
  var isEnableEdit:Bool = false {
    didSet {
      editButton.isHidden = !isEnableEdit
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    serchTF.returnKeyType = .search
    serchTF.clearButtonMode = .whileEditing
    serchTF.delegate = self
    isEnableEdit = false
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  @IBAction func editButtonAction(_ sender: Any) {
    editHandler?()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    if let text = serchTF.text {
      searchHandler?(text)
    }
    return true
  }
}
