//
//  DeclarationFormInPutCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/16.
//

import UIKit
import KMPlaceholderTextView
class DeclarationFormInputCell: UITableViewCell,UITextViewDelegate {
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var textView: KMPlaceholderTextView!
  var model:HealthDeclarationModel? {
    didSet {
      guard let model = model else {
        return
      }
      descLabel.text = model.description_en
      numLabel.text = model.index < 10 ? "Question 0\(model.index)" : "Question \(model.index)"
      textView.placeholder = model.placeholder
      if !model.text.isEmpty {
        textView.text = model.text
      }
    }
  }
  @IBOutlet weak var shadowView: UIView!
  
  var remarkDidChange:((HealthDeclarationModel)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func textViewDidChange(_ textView: UITextView) {
    remarkDidChange?(model!)
    model?.text = textView.text
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      self.endEditing(false)
      return false
    }
    return true
  }
}
