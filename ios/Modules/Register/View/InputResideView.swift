//
//  InputResideView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/8.
//

import UIKit
import TextFieldEffects
class InputResideView: UIView,UITextFieldDelegate {

  @IBOutlet weak var postalCodeTf: HoshiTextField!
  @IBOutlet weak var nextButon: LoadingButton!
  @IBOutlet weak var infoContentView: UIView!

  @IBOutlet weak var countryTf: HoshiTextField!
  @IBOutlet weak var cityTf: HoshiTextField!
  @IBOutlet weak var unitNumTf: HoshiTextField!
  @IBOutlet weak var streetNameTf: HoshiTextField!
  @IBOutlet weak var BlockNumTf: HoshiTextField!
  
  var postalCode = ""
  var blockNum = ""
  var streetName = ""
  var unitNum = ""
  var city = ""
  var country = ""
  
  var countries:[CountryModel] = []
  var userCountry:CountryModel?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    getCounties(false)
  }
  
  func getCounties(_ isGetBySelf:Bool) {
    let  params = SOAPParams(action: .Country, path: .getTCountries)
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      if let models = DecodeManager.decodeArrayByHandJSON(CountryModel.self, from: data) {
        self.countries = models
        self.setNextButonState()
        if isGetBySelf {
          self.showCountrySheet()
        }
      }
    } errorHandler: { e in
      Toast.dismiss()
    }

  }
  
  func setUserCountry() {
    if let user = Defaults.shared.get(for: .userModel) {
      let temp = countries.filter({ $0.id == user.country_id }).first
      if temp != nil {
        userCountry = temp
      }
    }else {
      userCountry = countries.filter({ $0.name == "Singapore" }).first
    }
    country = userCountry?.name ?? ""
    countryTf.text = country
    setNextButonState()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    infoContentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)

  }
  
  @IBAction func showCityAction(_ sender: Any) {
    endEditing(true)
    if countries.count > 0 {
      showCountrySheet()
    }else {
      Toast.showLoading()
      getCounties(true)
    }
  }
  
  func showCountrySheet() {
    let strs = countries.map({ $0.name })
    BookingServiceFormSheetView.show(dataArray: strs, type: .SelectCountry) { idx in
      self.userCountry = self.countries[idx]
      self.country = self.userCountry?.name ?? ""
      self.countryTf.text = self.country
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
    if textField == postalCodeTf {
      postalCode = text
    }
    if textField == BlockNumTf {
      blockNum = text
    }
    if textField == streetNameTf {
      streetName = text
    }
    if textField == unitNumTf {
      unitNum = text
    }
    if textField == cityTf {
      city = text
    }
    
    setNextButonState()
  }
  
  func setNextButonState() {
    let isEnable = !postalCode.isEmpty && !blockNum.isEmpty && !streetName.isEmpty && !unitNum.isEmpty
    if isEnable {
      nextButon.isEnabled = true
      nextButon.backgroundColor = R.color.theamRed()
    }else {
      nextButon.isEnabled = false
      nextButon.backgroundColor = R.color.grayE0()
    }
  }
}
