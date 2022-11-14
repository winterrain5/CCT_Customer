//
//  DeclarationFormRaceCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/10/9.
//

import UIKit
import KMPlaceholderTextView
class DeclarationFormRaceCell: UITableViewCell ,UITextViewDelegate {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var chineseBtn: UIButton!
  @IBOutlet weak var malayBtn: UIButton!
  @IBOutlet weak var indianBtn: UIButton!
  @IBOutlet weak var othersBtn: UIButton!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var textView: KMPlaceholderTextView!

  var selectedBtn:UIButton?
  var updateOptionsHandler:((HealthDeclarationModel)->())?
  var inputDidChange:((HealthDeclarationModel)->())?
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
 
      
      if model.result == "1" {
        updateSelectStatus(chineseBtn,result: "1")
      }

      if model.result == "2" {
        updateSelectStatus(malayBtn,result: "2")
      }

      if model.result == "3" {
        updateSelectStatus(indianBtn,result: "3")
      }
      
      if model.result == "4" {
        updateSelectStatus(othersBtn,result: "4")
      }
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
  @IBAction func chineseAction(_ sender: UIButton) {
    updateSelectStatus(sender,result: "1")
  }
  
  @IBAction func malayAction(_ sender: UIButton) {
    updateSelectStatus(sender,result: "2")
  }
  
  @IBAction func indianAction(_ sender: UIButton) {
    updateSelectStatus(sender,result: "3")
  }
  
  @IBAction func othersAction(_ sender: UIButton) {
    updateSelectStatus(sender,result: "4")
  }
  
  func updateSelectStatus(_ sender:UIButton,result:String) {
  
    if let sel = selectedBtn {
      normalStyle(sel)
    }
    
    selectStyle(sender)
    selectedBtn = sender
    
    if result == model?.result { return }
    model?.result = result
    updateOptionsHandler?(model!)
  }
  
  func selectStyle(_ btn:UIButton) {
    btn.backgroundColor = R.color.grayf2()
    btn.setTitleColor(R.color.theamRed(), for: .normal)
    btn.tintColor = R.color.theamRed()
  }
  func normalStyle(_ btn:UIButton) {
    btn.backgroundColor = R.color.white()
    btn.setTitleColor(R.color.grayBD(), for: .normal)
    btn.tintColor = R.color.grayBD()
  }
  
  func textViewDidChange(_ textView: UITextView) {
    inputDidChange?(model!)
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