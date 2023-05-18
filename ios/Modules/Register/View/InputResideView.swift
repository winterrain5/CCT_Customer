//
//  InputResideView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/8.
//

import UIKit
import TextFieldEffects
import SideMenuSwift
class InputResideView: UIView,UITextFieldDelegate {

  @IBOutlet weak var postalCodeTf: HoshiTextField!
  @IBOutlet weak var nextButon: LoadingButton!
  @IBOutlet weak var infoContentView: UIView!

  @IBOutlet weak var countryTf: HoshiTextField!
  @IBOutlet weak var cityTf: HoshiTextField!
  @IBOutlet weak var unitNumTf: HoshiTextField!
  @IBOutlet weak var streetNameTf: HoshiTextField!
  @IBOutlet weak var BlockNumTf: HoshiTextField!
  
  var countries:[CountryModel] = []
  var userCountry:CountryModel?
  
  var registInfo = Defaults.shared.get(for: .registModel)
  
  override func awakeFromNib() {
    super.awakeFromNib()
    getCounties(false)
    
    if let user = Defaults.shared.get(for: .userModel) {
      postalCodeTf.text = user.post_code
      registInfo?.postalCode = user.post_code
      
      BlockNumTf.text = user.building_block_num
      registInfo?.blockNum = user.building_block_num
      
      streetNameTf.text = user.street_name
      registInfo?.streetName = user.street_name
      
      unitNumTf.text = user.unit_num
      registInfo?.unitNum = user.unit_num
      
      cityTf.text = user.city
      registInfo?.city = user.city
      
      countryTf.text = user.country_name
      registInfo?.country_id = user.country_id

      setNextButonState()
    }
    
    setNextButonState()
  }
  
  func getCounties(_ isGetBySelf:Bool) {
    let params = SOAPParams(action: .Country, path: .getTCountries)
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      if let models = DecodeManager.decodeArrayByHandJSON(CountryModel.self, from: data) {
        self.countries = models
        self.setUserCountry()
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
  
  }
  
  func getFreeDiscountsForClient() {
    self.nextButon.startAnimation()
    let params = SOAPParams(action: .RewardDiscounts, path: .getSpecForRegister)

    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(DiscountModel.self, from: data) {
        self.registInfo?.present_reward_discount_id = model.id
        self.save()
      } else {
        self.save()
      }
    } errorHandler: { e in
      self.nextButon.stopAnimation()
    }

  }
  

  
  func save() {
    let mapParams = SOAPParams(action: .Client, path: .saveTClient)
    let data = SOAPDictionary()
    let client_info = SOAPDictionary()
    
    let user = Defaults.shared.get(for: .userModel)
    
    guard let registInfo = registInfo else {
      return
    }
    
    client_info.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    client_info.set(key: "id", value: user?.id ?? "")
    client_info.set(key: "first_name", value: registInfo.firstName)
    client_info.set(key: "last_name", value: registInfo.lastName)
    client_info.set(key: "mobile", value: registInfo.mobile)
    client_info.set(key: "phone", value: registInfo.mobile)
    client_info.set(key: "email", value: registInfo.email)
    client_info.set(key: "gender", value: registInfo.gender)
    client_info.set(key: "birthday", value: registInfo.dataOfBirth)
    client_info.set(key: "is_display_on_all_booking", value: "1")
    client_info.set(key: "card_number", value: registInfo.IcNum)
    client_info.set(key: "is_vip", value: "1")
    client_info.set(key: "city", value: registInfo.city)
    client_info.set(key: "country_id", value: registInfo.country_id)
    client_info.set(key: "present_cash_voucher", value: "")
    client_info.set(key: "present_invite_cash_voucher", value: "")
    client_info.set(key: "invite_code", value: registInfo.referralCode)
    client_info.set(key: "present_reward_discount", value: registInfo.present_reward_discount_id)
    client_info.set(key: "cct_or_mp", value: registInfo.isCustomer)
    client_info.set(key: "street_name", value: registInfo.streetName)
    client_info.set(key: "building_block_num", value: registInfo.blockNum)
    client_info.set(key: "unit_num", value: registInfo.unitNum)
    client_info.set(key: "post_code", value: registInfo.postalCode)
    client_info.set(key: "sync_phone_calendar", value: "1")
    client_info.set(key: "create_time", value: Date().string(withFormat: "yyyy-MM-dd HH:mm:ss"))
    client_info.set(key: "is_delete", value: "0")
    client_info.set(key: "source", value: "2")
    
    data.set(key: "Client_Info", value: client_info.result, keyType: .string, valueType: .map(1))
    
    let userInfo = SOAPDictionary()
    userInfo.set(key: "password", value: registInfo.password.md5)
    
    data.set(key: "User_Info", value: userInfo.result, keyType: .string, valueType: .map(1))
    
    mapParams.set(key: "data", value: data.result,type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(SaveClientModel.self, from: data) {
        Defaults.shared.set(model.client_id, for: .clientId)
        Defaults.shared.set(self.registInfo?.password ?? "", for: .loginPwd)
        self.sendNewUserSmsForEmail()
      }
    } errorHandler: { e in
      self.nextButon.stopAnimation()
    }

    
  }
  
  func sendNewUserSmsForEmail() {
    let mapParams = SOAPParams(action: .Sms, path: .sendSmsForEmail,isNeedToast: false)
    
    let params = SOAPDictionary()
    params.set(key: "title", value: "[Chien Chi Tow]")
    params.set(key: "email", value: registInfo?.email ?? "")
    let message = "You have successfully registered for your personal Chien Chi Tow App account. Welcome to Chien Chi Tow App, your personal health & wellness companion. Be rewarded and enjoy exclusive deals when you use the App. Check your CCT points that you have collected from your purchases. Use the App to make an appointment with us now!".replaceHTMLLabel()
    params.set(key: "message", value: message)
    params.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "")
    params.set(key: "from_email", value: Defaults.shared.get(for: .sendEmail) ?? "")
    params.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
    
    mapParams.set(key: "params", value: params.result, type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      self.setRootViewController()
    } errorHandler: { e in
      self.setRootViewController()
    }
    
    
   
  }
  
  func setRootViewController() {
    Defaults.shared.set(false, for: .isFirstLogin)
    DispatchQueue.main.async {
      let tab = BaseTabBarController()
      UIApplication.shared.keyWindow?.rootViewController = SideMenuController(contentViewController: tab, menuViewController: MenuViewController())
    }
    
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
      self.registInfo?.country_id = self.userCountry?.id ?? ""
      self.countryTf.text = self.userCountry?.name ?? ""
      self.setNextButonState()
    }
  }
  
  @IBAction func nextAction(_ sender: Any) {
    if Defaults.shared.get(for: .userModel) == nil {
      getFreeDiscountsForClient()
    }else {
      save()
    }
   
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let text = textField.text ?? ""
    if textField == postalCodeTf {
      registInfo?.postalCode = text
    }
    if textField == BlockNumTf {
      registInfo?.blockNum = text
    }
    if textField == streetNameTf {
      registInfo?.streetName = text
    }
    if textField == unitNumTf {
      registInfo?.unitNum = text
    }
    if textField == cityTf {
      registInfo?.city = text
    }
    
    setNextButonState()
  }
  
  func setNextButonState() {
//    let postalCode = registInfo?.postalCode ?? ""
//    let blockNum = registInfo?.blockNum ?? ""
//    let streetName = registInfo?.streetName ?? ""
//    let isEnable = !postalCode.isEmpty && !blockNum.isEmpty && !streetName.isEmpty
    
    nextButon.isEnabled = true
    nextButon.backgroundColor = R.color.theamRed()
    
//    if isEnable {
//      nextButon.isEnabled = true
//      nextButon.backgroundColor = R.color.theamRed()
//    }else {
//      nextButon.isEnabled = false
//      nextButon.backgroundColor = R.color.grayE0()
//    }
  }
}
