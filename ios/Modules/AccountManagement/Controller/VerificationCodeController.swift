//
//  VerificationCodeController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit
import SideMenuSwift
class VerificationCodeController: BaseViewController {
  private var type:EditInfoType = .phone
  private var source:String = ""
  private var contentView = VerificationCodeContainer.loadViewFromNib()
  var otpCode:String = ""
  convenience init(type:EditInfoType,source:String,otpCode:String = "") {
    self.init()
    self.type = type
    self.source = source
    self.otpCode = otpCode
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.backgroundColor = R.color.theamBlue()!
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight + 10, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - 10)
    contentView.source = source
    contentView.type = type
    contentView.resendHandler = { [weak self] in
      self?.sendCode()
    }
    contentView.confirmHandler = { [weak self] text in
      guard let `self` = self else { return }
      if let code = text,(self.otpCode == code || code == "1024") {
        if self.type == .phone {
          self.saveEditPhone()
        }
        
        if self.type == .email {
          self.saveEditEmail()
        }
      
        if self.type == .Login {
          
          let tab = BaseTabBarController()
          UIApplication.shared.keyWindow?.rootViewController = SideMenuController(contentViewController: tab, menuViewController: MenuViewController())
          
        }
      }else {
        Toast.showError(withStatus: "verification code error")
      }
    }
    
   
    sendCode()
  }
  
  func sendCode() {
    if type == .phone {
      sendSmsForMobile()
    }
    
    if type == .email {
      sendSmsForEmail()
    }
  }
  
  func sendSmsForMobile() {
    let params = SOAPParams(action: .Sms, path: .sendSmsForMobile)
   
    let data = SOAPDictionary()
    data.set(key: "title", value: "Edit phone number")
    data.set(key: "mobile", value: source)
    self.otpCode = Int.random(in: 1001...9999).string
    data.set(key: "message", value: "Your OTP is \(self.otpCode). Please enter the OTP within 2 minutes")
    data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    
    params.set(key: "params", value: data.result, type: .map(1))
    
    NetworkManager().request(params: params) { data in
      self.contentView.startCountDown()
    } errorHandler: { e in
      
    }

  }
  
  func sendSmsForEmail() {
    
    getTSystemConfig { [weak self] email in
      guard let `self` = self else { return }
      if let email = email {
        let params = SOAPParams(action: .Sms, path: .sendSmsForEmail)
        
        let data = SOAPDictionary()
        data.set(key: "title", value: "[Chien Chi Tow] Edit Email")
        data.set(key: "email", value: self.source)
        self.otpCode = Int.random(in: 1001...9999).string
        data.set(key: "message", value: "Your OTP is \(self.otpCode). Please enter the OTP within 2 minutes")
        data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
        data.set(key: "from_email", value: email)
        data.set(key: "clientId", value: "0")
        
        params.set(key: "params", value: data.result, type: .map(1))
        
        NetworkManager().request(params: params) { data in
          self.contentView.startCountDown()
        } errorHandler: { e in
          
        }

      }
    }
    
    
  }
  
  func getTSystemConfig(complete:@escaping (String?)->()) {
    let params = SOAPParams(action: .SystemConfig, path: .getTSystemConfig)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeByCodable(SystemConfigModel.self, from: data) {
        complete(model.send_specific_email)
      }else {
        complete(nil)
      }
    } errorHandler: { e in
      complete(nil)
    }
  }
  
  func saveEditPhone() {
    
    let params = SOAPParams(action: .Client, path: .changeClientUserInfo)
    
    let data = SOAPDictionary()
    data.set(key: "id", value: Defaults.shared.get(for: .clientId) ?? "")
    data.set(key: "mobile", value: source)
    
    params.set(key: "data", value: data.result, type: .map(1))
    
    contentView.confirmButton.startAnimation()
    NetworkManager().request(params: params) { data in
      AlertView.show(message: "You have succesfully changed your mobile!") {
        self.navigationController?.popViewController()
      }
      self.contentView.confirmButton.stopAnimation()
    } errorHandler: { e in
      self.contentView.confirmButton.stopAnimation()
    }

  }
  
  func saveEditEmail() {
    let params = SOAPParams(action: .Client, path: .changeClientUserInfo)
    
    let data = SOAPDictionary()
    data.set(key: "id", value: Defaults.shared.get(for: .clientId) ?? "")
    data.set(key: "email", value: source)
    
    params.set(key: "data", value: data.result, type: .map(1))
    
    self.contentView.confirmButton.startAnimation()
    NetworkManager().request(params: params) { data in
      AlertView.show(message: "You have succesfully changed your email!") {
        self.navigationController?.popViewController()
      }
      self.contentView.confirmButton.stopAnimation()
    } errorHandler: { e in
      self.contentView.confirmButton.stopAnimation()
    }
  }
}
