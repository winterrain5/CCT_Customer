//
//  DeclarationPurposeCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/10/9.
//

import UIKit

class DeclarationFormPurposeCell: UITableViewCell {

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var option1Btn: UIButton!
  @IBOutlet weak var option2Btn: UIButton!
  @IBOutlet weak var othersBtn: UIButton!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!

  var selectedBtn:UIButton?
  var updateOptionsHandler:((HealthDeclarationModel)->())?
  var inputDidChange:((HealthDeclarationModel)->())?
  var model:HealthDeclarationModel? {
    didSet {
      guard let model = model else {
        return
      }

      descLabel.text = model.description_en
      numLabel.text = model.questionNum
 
      
      if model.result == "1" {
        updateSelectStatus(option1Btn,result: "1")
      }

      if model.result == "2" {
        updateSelectStatus(option2Btn,result: "2")
      }

      if model.result == "3" {
        updateSelectStatus(othersBtn,result: "3")
      }
      

    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
  @IBAction func option1Action(_ sender: UIButton) {
    updateSelectStatus(sender,result: "1")
  }
  
  @IBAction func option12Action(_ sender: UIButton) {
    updateSelectStatus(sender,result: "2")
  }
  

  @IBAction func othersAction(_ sender: UIButton) {
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
