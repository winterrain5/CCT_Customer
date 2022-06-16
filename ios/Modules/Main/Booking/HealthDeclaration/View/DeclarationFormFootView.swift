//
//  DeclarationFormFootView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit

class DeclarationFormFootView: UIView {
  @IBOutlet weak var isCheckButton: UIButton!
  @IBOutlet weak var nextButon: LoadingButton!
  var confirmHander:((LoadingButton)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    
    isCheckButton.imageForNormal = R.image.symptom_check_box_unselect()
    isCheckButton.tintColor = R.color.grayE0()
    isCheckButton.borderColor = UIColor(hexString: "777777")
    setNextButonState(isEnable: false)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  @IBAction func isCheckAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      sender.borderColor = .clear
      sender.tintColor = R.color.white()
      sender.imageForNormal = R.image.symptom_check_box_select()
    }else {
      sender.imageForNormal = R.image.symptom_check_box_unselect()
      sender.tintColor = R.color.grayE0()
      sender.borderColor = UIColor(hexString: "777777")
     
    }
    
    setNextButonState(isEnable: sender.isSelected)
  }
  
  
  @IBAction func nextAction(_ sender: Any) {
    confirmHander?(nextButon)
  }

  
  func setNextButonState(isEnable:Bool) {
   
    if isEnable {
      nextButon.isEnabled = true
      nextButon.backgroundColor = R.color.theamRed()
    }else {
      nextButon.isEnabled = false
      nextButon.backgroundColor = R.color.grayE0()
    }
  }
}
