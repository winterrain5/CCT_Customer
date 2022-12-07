//
//  DeclarationFormFocusAreaCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/16.
//

import UIKit

class DeclarationFormFocusAreaCell: UITableViewCell {

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  var isSelect = false
  var updateOptionsHandler:((HealthDeclarationModel)->())?
  var model:HealthDeclarationModel? {
    didSet {
      guard let model = model else {
        return
      }

      descLabel.text = model.description_en
      numLabel.text = model.questionNum
      
      updateSelectStatus(0, result: model.focus_on_head)
      updateSelectStatus(1, result: model.focus_on_neck)
      updateSelectStatus(2, result: model.focus_on_arms)
      updateSelectStatus(3, result: model.focus_on_shoulders)
      updateSelectStatus(4, result: model.focus_on_legs)
      updateSelectStatus(5, result: model.focus_on_back)
      
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
 
  @IBAction func focusAreaAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      selectStyle(sender)
      updateData(sender, result: 1)
    }else {
      normalStyle(sender)
      updateData(sender, result: 0)
    }
    
  }
  
  
  
  func updateSelectStatus(_ tag:Int,result:Int) {
    let sender = stackView.subviews.filter({ $0.tag == tag }).first as! UIButton
    if result == 1 {
      focusAreaAction(sender)
    }
  }
  
  func updateData(_ sender:UIButton,result:Int) {
    let tag = sender.tag
    switch tag {
    case 0:
      model?.focus_on_head = result
    case 1:
      model?.focus_on_neck = result
    case 2:
      model?.focus_on_arms = result
    case 3:
      model?.focus_on_shoulders = result
    case 4:
      model?.focus_on_legs = result
    case 5:
      model?.focus_on_back = result
    default:
      print("none of cased")
    }
  }
  
  func selectStyle(_ btn:UIButton) {
    btn.backgroundColor = R.color.grayf2()
    btn.tintColor = .clear
    btn.setTitleColor(R.color.theamRed(), for: .selected)
  }
  func normalStyle(_ btn:UIButton) {
    btn.backgroundColor = R.color.white()
    btn.tintColor = .clear
    btn.setTitleColor(R.color.grayBD(), for: .normal)
  }
    
}
