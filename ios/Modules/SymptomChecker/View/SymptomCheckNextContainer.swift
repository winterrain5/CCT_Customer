//
//  SymptomCheckNextContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckNextContainer: UIView {

  @IBOutlet weak var beginButton: UIButton!
  @IBOutlet weak var checkboxButton: UIButton!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var confirmLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    beginButton.backgroundColor = UIColor(hexString: "dddddd")
    beginButton.isEnabled = false
    
    checkboxButton.borderColor = UIColor(hexString: "777777")
    checkboxButton.imageForNormal = R.image.symptom_check_box_unselect()
    
    descLabel.textAlignment = .left
    confirmLabel.textAlignment = .left
    
    let str1 = "This tool can provide an overview of conditions related to "
    let str2 = "bone, muscle and joints"
    let str3 = ". Results presented is not a medical diagnosis and indication of your condition. Please visit our professional physicians for a comprehensive analysis of your condition."
    let str = str1 + str2 + str3
    let attr = NSMutableAttributedString(string: str)
    attr.addAttribute(.font, value: UIFont(.AvenirNextDemiBold,16), range: NSRange(location: str1.count, length: str2.count))
    descLabel.attributedText = attr
    
  }
  @IBAction func checkboxButtonAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      beginButton.backgroundColor = R.color.theamRed()
      beginButton.isEnabled = true
      
      checkboxButton.borderColor = .clear
      checkboxButton.imageForNormal = R.image.symptom_check_box_select()
    }else {
      beginButton.backgroundColor = UIColor(hexString: "dddddd")
      beginButton.isEnabled = false
      
      checkboxButton.borderColor = UIColor(hexString: "777777")
      checkboxButton.imageForNormal = R.image.symptom_check_box_unselect()
    }
  }
  
  @IBAction func beginButtonAction(_ sender: UIButton) {
    let vc = SymptomCheckStepController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
}
