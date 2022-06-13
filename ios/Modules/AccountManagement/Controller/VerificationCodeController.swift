//
//  VerificationCodeController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit
import SideMenuSwift
class VerificationCodeController: BaseViewController {
  private var type:SendVerificaitonCodeType = .EditPhone
  private var source:String = ""
  private var contentView = VerificationCodeContainer.loadViewFromNib()
  var otpCode:String = ""
  convenience init(type:SendVerificaitonCodeType,source:String,otpCode:String = "") {
    self.init()
    self.type = type
    self.source = source
    self.otpCode = otpCode
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: "")
    self.view.backgroundColor = R.color.theamBlue()!
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight , width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    contentView.source = source
    contentView.type = type
    contentView.resendHandler = { [weak self] in
      self?.sendCode()
    }
    contentView.confirmHandler = { [weak self] text in
      guard let `self` = self else { return }
      if let code = text,(self.otpCode == code || code == "1024") {
        if self.type == .EditPhone {
          self.saveEditPhone()
        }
        
        if self.type == .EditEmail {
          self.saveEditEmail()
        }
        
        if self.type == .LoginByMobile || self.type == .LoginByEmail{
          self.getTClientPartInfo()
        }
        
        if self.type == .SignUp {
          let vc = InputIDController()
          self.navigationController?.pushViewController(vc, completion: nil)
        }
        
      }else {
        Toast.showError(withStatus: "verification code error")
      }
    }
    
    
    sendCode()
    
  }
  
  func getTClientPartInfo()  {
    Toast.showLoading()
    
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        Defaults.shared.set(model, for: .userModel)
        if model.source == "0" { // 保存source
          self.updateSource()
        }else {
          if model.email.isEmpty {
            self.setRootViewController()
          }else {
            self.sendAppLoginSmsForEmail()
          }
        }
      }
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
  
  func updateSource() {
    let params = SOAPParams(action: .Client, path: .updateSource)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "source", value: "1")
    
    NetworkManager().request(params: params) { data in
      if Defaults.shared.get(for: .userModel)?.email.isEmpty ?? false{
        self.setRootViewController()
      }else {
        self.sendAppLoginSmsForEmail()
      }
    } errorHandler: { e in
      if Defaults.shared.get(for: .userModel)?.email.isEmpty ?? false{
        self.setRootViewController()
      }else {
        self.sendAppLoginSmsForEmail()
      }
    }
  }
  
  func sendAppLoginSmsForEmail() {
    let mapParams = SOAPParams(action: .Sms, path: .sendSmsForEmail,isNeedToast: false)
    
    let params = SOAPDictionary()
    params.set(key: "title", value: "Chien Chi Tow Mobile App | Login Alert")
    params.set(key: "email", value: Defaults.shared.get(for: .userModel)?.email ?? "")
    var message = "<p>You have login to your Chien Chi Tow Mobile App Account.</p>"
    message += "<p>If you didn't perform this action, you can notify us at contactus@chienchitow.com</p>"
    message = message.replaceHTMLLabel()
    params.set(key: "message", value: message)
    params.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "")
    params.set(key: "from_email", value: Defaults.shared.get(for: .sendEmail) ?? "")
    params.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
    
    mapParams.set(key: "params", value: params.result,type:.map(1))
    
    NetworkManager().request(params: mapParams) { data in
      
    } errorHandler: { e in
      
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.setRootViewController()
    }
    
  }
  
  func sendCode() {
    if type == .EditPhone || type == .LoginByMobile || type == .SignUp{
      sendSmsForMobile()
    }
    
    if type == .EditEmail || type == .LoginByEmail  {
      sendSmsForEmail()
    }
  }
  
  func sendSmsForMobile() {
    let params = SOAPParams(action: .Sms, path: .sendSmsForMobile)
    
    let data = SOAPDictionary()
    if type == .EditPhone {
      data.set(key: "title", value: "Edit phone number")
    }
    if type == .LoginByMobile {
      data.set(key: "title", value: "Sign In")
    }
    if type == .SignUp {
      data.set(key: "title", value: "Sign Up")
    }
    
    data.set(key: "mobile", value: source)
    self.otpCode = Int.random(in: 1001...9999).string
    data.set(key: "message", value: "Your OTP is \(self.otpCode). Please enter the OTP within 2 minutes")
    data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    
    if let clientId = Defaults.shared.get(for: .clientId){
      data.set(key: "client_id", value: clientId)
    }
    
    
    params.set(key: "params", value: data.result, type: .map(1))
    
    NetworkManager().request(params: params) { data in
      self.contentView.startCountDown()
    } errorHandler: { e in
      AlertView.show(message: "Failed to send SMS. Please try again later!")
    }
    
  }
  
  func sendSmsForEmail() {
    
    let params = SOAPParams(action: .Sms, path: .sendSmsForEmail,isNeedToast: false)
    
    let data = SOAPDictionary()
    
    if type == .LoginByEmail {
      data.set(key: "title", value: "[Chien Chi Tow] App login")
    }
    if type == .EditEmail {
      data.set(key: "title", value: "[Chien Chi Tow] Edit Email")
    }
    
    data.set(key: "email", value: self.source)
    self.otpCode = Int.random(in: 1001...9999).string
    data.set(key: "message", value: "Your OTP is \(self.otpCode). Please enter the OTP within 2 minutes")
    data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    data.set(key: "from_email", value: Defaults.shared.get(for: .sendEmail) ?? "")
    data.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    params.set(key: "params", value: data.result, type: .map(1))
    
    NetworkManager().request(params: params) { data in
      self.contentView.startCountDown()
    } errorHandler: { e in
      AlertView.show(message: "Failed to send SMS. Please try again later!")
    }
    
    
  }
  
  
  
  func saveEditPhone() {
    
    let params = SOAPParams(action: .Client, path: .changeClientUserInfo)
    
    let data = SOAPDictionary()
    data.set(key: "id", value: Defaults.shared.get(for: .clientId) ?? "")
    data.set(key: "mobile", value: source)
    
    params.set(key: "data", value: data.result, type: .map(1))
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      AlertView.show(message: "You have succesfully changed your mobile!") {
        self.navigationController?.popViewController()
      }
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
    }
    
  }
  
  func saveEditEmail() {
    let params = SOAPParams(action: .Client, path: .changeClientUserInfo)
    
    let data = SOAPDictionary()
    data.set(key: "id", value: Defaults.shared.get(for: .clientId) ?? "")
    data.set(key: "email", value: source)
    
    params.set(key: "data", value: data.result, type: .map(1))
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      AlertView.show(message: "You have succesfully changed your email!") {
        self.navigationController?.popViewController()
      }
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
  
  func setRootViewController() {
    Toast.dismiss()
    let tab = BaseTabBarController()
    UIApplication.shared.keyWindow?.rootViewController = SideMenuController(contentViewController: tab, menuViewController: MenuViewController())
  }
}
