//
//  DeclarationFormMethodOfDeiveryCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit

class DeclarationFormMethodOfDeiveryCell: UITableViewCell {

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var naturalBirthBtn: UIButton!
  @IBOutlet weak var cSectionBtn: UIButton!
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
      numLabel.text = model.questionNum
      
      if model.mehtod_of_delivery == "1" {
        updateSelectStatus(naturalBirthBtn, result: "1")
        
      }

      if model.mehtod_of_delivery == "2" {
        updateSelectStatus(cSectionBtn, result: "2")
      }
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
  @IBAction func cSectionAction(_ sender: UIButton) {
    updateSelectStatus(sender,result: "2")
  }
  
  @IBAction func naturalBirth(_ sender: UIButton) {
    updateSelectStatus(sender,result: "1")
  }
  
  func updateSelectStatus(_ sender:UIButton,result:String) {
  
    if let sel = selectedBtn {
      normalStyle(sel)
    }
    
    selectStyle(sender)
    selectedBtn = sender
    
    if result == model?.mehtod_of_delivery { return }
    model?.mehtod_of_delivery = result
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
