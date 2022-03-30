//
//  ProductLeaveReviewSheetFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/21.
//

import UIKit
import KMPlaceholderTextView
import IQKeyboardManagerSwift
class ProductLeaveReviewSheetFooterView: UIView,UITextViewDelegate {
  
  @IBOutlet weak var textViewHCons: NSLayoutConstraint!
  @IBOutlet weak var starContentView: StarRateView!
  @IBOutlet weak var loyatlyLabel: UILabel!
  @IBOutlet weak var textView: KMPlaceholderTextView!
  var textFieldDidEditingHandler:((String)->())?
  
  var leaveReviewPoints:String = "" {
    didSet {
      loyatlyLabel.text = "Complete the review and recieved \(leaveReviewPoints) loyalty points"
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    starContentView.selectStarUnit = .all
    starContentView.hightLightImage = R.image.madam_partum_star()
    starContentView.defaultImage = R.image.madam_partum_un_star()
    textView.delegate = self
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      endEditing(true)
      return false
    }
    return true
  }
  
  func textViewDidChange(_ textView: UITextView) {
    textFieldDidEditingHandler?(textView.text ?? "")
    let size = textView.sizeThatFits(CGSize(width: textView.width, height: CGFloat.infinity))
    textViewHCons.constant = size.height
    UIView.animate(withDuration: 0.1) {
      IQKeyboardManager.shared.reloadLayoutIfNeeded()
      self.layoutIfNeeded()
    }
  }
  func textViewDidEndEditing(_ textView: UITextView) {
    textFieldDidEditingHandler?(textView.text ?? "")
  }
  
}
