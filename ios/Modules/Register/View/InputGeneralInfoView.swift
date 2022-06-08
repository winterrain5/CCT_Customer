//
//  InputGeneralInfoView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/8.
//

import UIKit

class InputGeneralInfoView: UIView {
  
  @IBOutlet weak var firstNameTf: UITextField!
  @IBOutlet weak var lastNameTf: UITextField!
  
  @IBOutlet weak var maleButton: UIButton!
  @IBOutlet weak var femaleButton: UIButton!
  var genderSelectedButton:UIButton?
  
  @IBOutlet weak var yesButton: UIButton!
  @IBOutlet weak var noButton: UIButton!
  var madamPartumSelectedButton:UIButton?
  
  @IBOutlet weak var birthTf: UITextField!
  
  @IBOutlet weak var referralCodeTf: UITextField!
  
  
  @IBOutlet weak var nextButon: UIButton!
  
  @IBOutlet weak var isCheckButton: UIButton!
  
  @IBOutlet weak var infoContentView: UIView!

  
  var gender = ""
  var isCustomer = ""
  var firstName = ""
  var lastName = ""
  var referralCode = ""
  var dateOfBirth = ""
  var isChecked = true
  
  override func awakeFromNib() {
    super.awakeFromNib()
    isCheckButton.borderColor = .clear
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    infoContentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)

  }
  
  @IBAction func isCheckAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      sender.imageForNormal = R.image.symptom_check_box_unselect()
      sender.backgroundColor = R.color.grayE0()
      sender.borderColor = UIColor(hexString: "777777")
    }else {
      sender.borderColor = .clear
      sender.imageForNormal = R.image.symptom_check_box_select()
    }
    isChecked = !sender.isSelected
    setNextButonState()
  }
  
  
  @IBAction func genderButtonAction(_ sender: UIButton) {
    if let sel = genderSelectedButton {
      sel.isSelected = false
    }
    sender.isSelected = !sender.isSelected
    if sender == maleButton {
      gender = "1"
    }else {
      gender = "2"
    }
    genderSelectedButton = sender
    setNextButonState()
  }
  
  
  @IBAction func madamPartumButtonAction(_ sender: UIButton) {
    if let sel = madamPartumSelectedButton {
      sel.isSelected = false
    }
    sender.isSelected = !sender.isSelected
    if sender == yesButton {
      isCustomer = "1"
    }else {
      isCustomer = "2"
    }
    madamPartumSelectedButton = sender
    setNextButonState()
  }
  
  @IBAction func showCalendarAction(_ sender: Any) {
    DateOfBirthSheetView.show { date in
      self.dateOfBirth = date.dateString()
      self.birthTf.text = date.dateString()
    }
  }
  
  @IBAction func nextAction(_ sender: Any) {
    let vc = InputResideController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let text = textField.text ?? ""
    if textField == firstNameTf {
      firstName = text
    }
    if textField == lastNameTf {
      lastName = text
    }
    
    if textField == referralCodeTf {
      referralCode = text
    }
    setNextButonState()
  }
  
  func setNextButonState() {
    let isEnable = !firstName.isEmpty && !lastName.isEmpty && !gender.isEmpty && !dateOfBirth.isEmpty && !isCustomer.isEmpty && isChecked
    if isEnable {
      nextButon.isEnabled = true
      nextButon.backgroundColor = R.color.theamRed()
    }else {
      nextButon.isEnabled = false
      nextButon.backgroundColor = R.color.grayE0()
    }
  }
}
