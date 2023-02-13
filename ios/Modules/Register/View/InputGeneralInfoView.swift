//
//  InputGeneralInfoView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/8.
//

import UIKit

class InputGeneralInfoView: UIView, UITextFieldDelegate {
  
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
  
  
  @IBOutlet weak var nextButon: LoadingButton!
  
  @IBOutlet weak var isCheckButton: UIButton!
  
  @IBOutlet weak var infoContentView: UIView!

  @IBOutlet weak var referralCodeView: UIView!
  
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
    
    if let user = Defaults.shared.get(for: .userModel) {

      if !user.gender.isEmpty {
        if user.gender == "1" {
          genderButtonAction(maleButton)
        }else {
          genderButtonAction(femaleButton)
        }
        gender = user.gender
      }
    
      if !user.cct_or_mp.isEmpty {
        if user.cct_or_mp == "2" {
          madamPartumButtonAction(yesButton)
        }else {
          madamPartumButtonAction(noButton)
        }
        isCustomer = user.cct_or_mp
      }
     
      
      birthTf.text = user.birthday
      firstName = user.first_name
      lastName = user.last_name
      dateOfBirth = user.birthday
      referralCodeView.isHidden = true
      
      setNextButonState()
    }else {
      referralCodeView.isHidden = false
    }
    
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
    endEditing(true)
    setNextButonState()
  }
  
  
  @IBAction func madamPartumButtonAction(_ sender: UIButton) {
    if let sel = madamPartumSelectedButton {
      sel.isSelected = false
    }
    sender.isSelected = !sender.isSelected
    if sender == yesButton {
      isCustomer = "2"
    }else {
      isCustomer = "1"
    }
    madamPartumSelectedButton = sender
    endEditing(true)
    setNextButonState()
  }
  
  @IBAction func showCalendarAction(_ sender: Any) {
    DatePickerSheetView.show(maximumDate:Date()) { date in
      let dateStr = date.string(withFormat: "yyyy-MM-dd")
      self.dateOfBirth = dateStr
      self.birthTf.text = dateStr
      self.setNextButonState()
      
    }
  }
  
  @IBAction func nextAction(_ sender: Any) {
   
    if let registInfo = Defaults.shared.get(for: .registModel) {
      registInfo.firstName = firstName
      registInfo.lastName = lastName
      registInfo.gender = gender
      registInfo.dataOfBirth = dateOfBirth
      registInfo.isCustomer = isCustomer
      registInfo.referralCode = referralCode
      Defaults.shared.set(registInfo, for: .registModel)
    }
    nextButon.stopAnimation()
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
      if !text.isEmpty {
        referralCode = text
        checkReferralCodeExist()
      }
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
  
  func checkReferralCodeExist() {
    
    let params = SOAPParams(action: .Client, path: .checkReferralCodeExists)
    params.set(key: "code", value: referralCode)
    NetworkManager().request(params: params) { data in
      let data = String(data: data, encoding: .utf8)
      if data != "1" {
        AlertView.show(message: "The current invitation code is incorrect, please check!")
      }
    } errorHandler: { e in
      
    }

  }
  
}
