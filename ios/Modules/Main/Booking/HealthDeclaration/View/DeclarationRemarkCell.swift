//
//  DeclarationRemarkCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit
import IQKeyboardManagerSwift
class DeclarationRemarkCell: UITableViewCell,UITextViewDelegate {
  @IBOutlet weak var textHCons: NSLayoutConstraint!
  var model:HealthDeclarationModel?
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
    let size = textView.sizeThatFits(CGSize(width: textView.width, height: CGFloat.infinity))
    textHCons.constant = size.height + 12
    UIView.animate(withDuration: 0.1) {
      IQKeyboardManager.shared.reloadLayoutIfNeeded()
      self.layoutIfNeeded()
    }
    model?.remark = textView.text
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      self.endEditing(false)
      return false
    }
    return true
  }
  
}
