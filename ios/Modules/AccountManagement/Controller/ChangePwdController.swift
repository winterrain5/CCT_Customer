//
//  ChangePwdController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/23.
//

import UIKit
import PromiseKit
class ChangePwdController: BaseViewController {
  var contentView = ChangePwdContainer.loadViewFromNib()
  private var type:EditPwdType = .Change
  private var receiveEmail:String = ""
  private var uuid:String = ""
  convenience init(type:EditPwdType,receiveEmail:String = "",uuid:String = "") {
    self.init()
    self.type = type
    self.uuid = uuid
    if receiveEmail.isEmpty {
      self.getClientInfo()
    }else {
      self.receiveEmail = receiveEmail
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.backgroundColor = R.color.theamBlue()!
    self.view.addSubview(contentView)
    contentView.type = type
    contentView.frame = CGRect(x: 0, y: kNavBarHeight + 10, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - 10)
    contentView.confirmHandler = { [weak self] text in
      guard let `self` = self else { return }
      self.contentView.confirmButton.startAnimation()
      if self.type == .Change {
        self.changePwd(text)
      }else {
        self.resetPwd(text)
      }
    }
  }
  
  func getClientInfo() {
    let parmas = SOAPParams(action: .Client, path: .getTClientPartInfo)
    parmas.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: parmas) { data in
      if let model = DecodeManager.decodeByCodable(UserModel.self, from: data) {
        self.receiveEmail = model.email ?? ""
      }
    } errorHandler: { e in
      
    }

  }
  
  func resetPwd(_ pwd:String) {
    firstly{
      self.getIdByEmail()
    }.then{
      self.getFindPasswordUUID()
    }.then {
      self.changeUserInfo(pwd)
    }.then { () -> Promise<String> in
      AlertView.show(message: "Your password has been succesfully changed.") {
        self.navigationController?.popToRootViewController(animated: true)
      }
      Defaults.shared.set(pwd, for: .loginPwd)
      return self.getTSystemConfig()
    }.then { email in
      self.sendSmsForEmail(email)
    }.done {
      self.contentView.confirmButton.stopAnimation()
    }.catch { e in
      Toast.showError(withStatus: e.asAPIError.errorInfo().message)
      self.contentView.confirmButton.stopAnimation()
    }
  }
  
  func changePwd(_ pwd:String) {
    firstly{
      self.changeUserInfo(pwd)
    }.then { () -> Promise<String> in
      Defaults.shared.set(pwd, for: .loginPwd)
      return self.getTSystemConfig()
    }.then { email in
      self.sendSmsForEmail(email)
    }.done {
      AlertView.show(message: "Your password has been succesfully changed.") {
        self.navigationController?.popViewController()
      }
      self.contentView.confirmButton.stopAnimation()
    }.catch { e in
      Toast.showError(withStatus: e.asAPIError.errorInfo().message)
      self.contentView.confirmButton.stopAnimation()
    }
  }
  
  func changeUserInfo(_ pwd:String) -> Promise<Void> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Client, path: .changeClientUserInfo)
      
      let data = SOAPDictionary()
      data.set(key: "id", value: Defaults.shared.get(for: .clientId) ?? "")
      data.set(key: "password", value: pwd.md5)
      
      params.set(key: "data", value: data.result,type: .map(1))
      
      NetworkManager().request(params: params) { data in
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(e)
      }
      
    }
  }
  
  func getIdByEmail() -> Promise<Void> {
    Promise.init { resolver in
      
      if let clientId = Defaults.shared.get(for: .clientId),!clientId.isEmpty {
        resolver.fulfill_()
        return
      }
      
      let params = SOAPParams(action: .Client, path: .getIdByEmail)
      params.set(key: "email", value: receiveEmail)
      NetworkManager().request(params: params) { data in
        if let clientId = JSON.init(from: data)?.stringValue.int {
          Defaults.shared.set(clientId.string, for: .clientId)
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Get ClientId By Email Failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  func getFindPasswordUUID() -> Promise<Void> {
    Promise.init { resolver in
      let params = SOAPParams(action: .User, path: .getFindPasswordUUID)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "uuid", value: self.uuid)
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByCodable(FindPwdStatusModel.self, from: data) {
          if model.status == "2" {
            resolver.fulfill_()
          }else {
            resolver.reject(APIError.requestError(code: -1, message: "Please go to email to confirm the link"))
          }
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "decode FindPwdStatusModel failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)  
      }

    }
  }
  
  func getTSystemConfig() -> Promise<String> {
    Promise.init { resolver in
      let params = SOAPParams(action: .SystemConfig, path: .getTSystemConfig)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByCodable(SystemConfigModel.self, from: data) {
          resolver.fulfill(model.send_specific_email ?? "")
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode SystemConfigModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  func sendSmsForEmail(_ email:String) -> Promise<Void> {
    Promise.init { resolver in
      
      if self.receiveEmail.isEmpty {
        resolver.reject(APIError.requestError(code: -1, message: "Email is empty"))
        return
      }
      
      let params = SOAPParams(action: .Sms, path: .sendSmsForEmail)
      
      let data = SOAPDictionary()
      data.set(key: "title", value: "[Chien Chi Tow]")
      data.set(key: "email", value: self.receiveEmail)
      
      var message = "<p>You have successfully changed your login password on " + Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
      message += "</p>.<p>If you did not authorise this action, please contact us immediately at 62 933 933.</p>";
      
      data.set(key: "message", value: message.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;"))
      
      data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      data.set(key: "from_email", value: email)
      data.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      params.set(key: "params", value: data.result, type: .map(1))
      
      NetworkManager().request(params: params) { data in
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
}
