//
//  EditProfileContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/1.
//

import UIKit

class EditProfileContainer: UIView,UITextFieldDelegate {

  @IBOutlet weak var firstNameTf: UITextField!
  @IBOutlet weak var lastNameTf: UITextField!
  
  @IBOutlet weak var maleButton: UIButton!
  @IBOutlet weak var femaleButton: UIButton!
  var genderSelectedButton:UIButton?
  
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var postCodeTf: UITextField!
  @IBOutlet weak var streetNameTf: UITextField!
  @IBOutlet weak var buildNumTf: UITextField!
  @IBOutlet weak var unitNumTf: UITextField!
  @IBOutlet weak var cityTf: UITextField!
  
  @IBOutlet weak var yesButton: UIButton!
  @IBOutlet weak var noButton: UIButton!
  var madamPartumSelectedButton:UIButton?
  
  var editModel = EditProfileModel()
  var userModel:UserModel? {
    didSet {
      guard let model = userModel else { return }
      firstNameTf.text = model.first_name
      lastNameTf.text = model.last_name
      
      genderButtonAction(model.gender == "1" ? maleButton : femaleButton)
      madamPartumButtonAction(model.cct_or_mp == "1" ? yesButton : noButton)
      dateLabel.text = model.birthday
      
      postCodeTf.text = model.post_code
      streetNameTf.text = model.street_name
      buildNumTf.text = model.building_block_num
      unitNumTf.text = model.unit_num
      cityTf.text = model.unit_num
      
      editModel.firstName = model.first_name
      editModel.lastName = model.last_name
      editModel.gender = model.gender
      editModel.postCode = model.post_code
      editModel.streetName = model.street_name
      editModel.buildingNum = model.building_block_num
      editModel.unitNum = model.unit_num
      editModel.city = model.city
      editModel.isCustomer = model.cct_or_mp
      editModel.birthday = model.birthday 
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    firstNameTf.delegate = self
    lastNameTf.delegate = self
    postCodeTf.delegate = self
    streetNameTf.delegate = self
    buildNumTf.delegate = self
    unitNumTf.delegate = self
    cityTf.delegate = self
    
    getUserInfo()
  }
  
  func getUserInfo() {
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        self.userModel = model
        Defaults.shared.set(model, for: .userModel)
      }
    } errorHandler: { e in
      
    }

  }
  
  @IBAction func genderButtonAction(_ sender: UIButton) {
    if let sel = genderSelectedButton {
      sel.isSelected = false
    }
    sender.isSelected = !sender.isSelected
    if sender == maleButton {
      editModel.gender = "1"
    }else {
      editModel.gender = "2"
    }
    genderSelectedButton = sender
  }
  
  @IBAction func dateLockButtonAction(_ sender: UIButton) {
    AlertView.show(title: "Locked Information", message: "For security reasons, you will not be able to make changes to your Date of Birth.\n\nPlease contact our staff or visit our nearby Chien Chi Tow outlet should you want to make any changes to this information")
  }
  @IBAction func madamPartumButtonAction(_ sender: UIButton) {
    if let sel = madamPartumSelectedButton {
      sel.isSelected = false
    }
    sender.isSelected = !sender.isSelected
    if sender == yesButton {
      editModel.isCustomer = "1"
    }else {
      editModel.isCustomer = "2"
    }
    madamPartumSelectedButton = sender
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let text = textField.text ?? ""
    if textField == firstNameTf {
      editModel.firstName = text
    }
    if textField == lastNameTf {
      editModel.lastName = text
    }
    if textField == postCodeTf {
      editModel.postCode = text
    }
    if textField == streetNameTf {
      editModel.streetName = text
    }
    if textField == buildNumTf {
      editModel.buildingNum = text
    }
    if textField == unitNumTf {
      editModel.unitNum = text
    }
    if textField == cityTf {
      editModel.city = text
    }
  }
}

class EditProfileModel {
  var firstName:String = ""
  var lastName:String = ""
  var gender:String = ""
  var postCode:String = ""
  var streetName:String = ""
  var buildingNum:String = ""
  var unitNum:String = ""
  var city:String = ""
  var isCustomer:String = ""
  var birthday:String = ""
}
