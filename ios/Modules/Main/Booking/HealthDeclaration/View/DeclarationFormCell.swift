//
//  DeclarationFormCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit

class DeclarationFormCell: UITableViewCell {
  
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var unsureBtn: UIButton!
  @IBOutlet weak var YesBtn: UIButton!
  @IBOutlet weak var noBtn: UIButton!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  var selectedBtn:UIButton?
  var updateOptionsHandler:((HealthDeclarationModel)->())?
  var model:HealthDeclarationModel? {
    didSet {
      guard let model = model else {
        return
      }

      descLabel.text = model.description_en
      numLabel.text = model.index < 10 ? "Question 0\(model.index)" : "Question \(model.index)"
      
      if model.result == "1" {
        updateSelectStatus(noBtn,result: "1")
      }

      if model.result == "2" {
        updateSelectStatus(YesBtn,result: "2")
      }

      if  model.result == "3" || model.result == "0" {
        updateSelectStatus(unsureBtn,result: "3")
      }
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
  @IBAction func noAction(_ sender: UIButton) {
    updateSelectStatus(sender,result: "1")
  }
  
  @IBAction func yesAction(_ sender: UIButton) {
    updateSelectStatus(sender,result: "2")
  }
  
  @IBAction func unSureAction(_ sender: UIButton) {
    updateSelectStatus(sender,result: "3")
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
  
}