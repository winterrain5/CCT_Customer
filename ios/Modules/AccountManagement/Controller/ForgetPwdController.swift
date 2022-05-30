//
//  ForgetPwdController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/23.
//

import UIKit
import PromiseKit
class ForgetPwdController: BaseViewController {
  private var contentView = ForgetPwdContainer.loadViewFromNib()
  private let uuid = UUID().uuidString.prefix(6)
  private var recieveEmail:String = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.backgroundColor = R.color.theamBlue()!
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight + 10, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - 10)
    contentView.confirmHandler = { [weak self] text in
      if let email = Defaults.shared.get(for: .userModel)?.email,email == text {
        self?.recieveEmail = email
        self?.process()
      }else {
        Toast.showError(withStatus: "The input Email is inconsistent with the current login Email")
      }
    }
  }
  
  func process() {
    contentView.confirmButton.startAnimation()
    firstly {
      saveFindPasswordUUID()
    }.then {
      self.getTSystemConfig()
    }.then { email in
      self.sendSmsForEmail(email)
    }.done {
      let line1 = "An email has already been sent to \n"
      let line2 = self.recieveEmail
      let lien3 = "\n\nPlease check to reset your password"
      
      let message = line1 + line2 + lien3
      let attr = NSMutableAttributedString(string: message)
      attr.addAttribute(.foregroundColor, value: R.color.theamRed()!, range: NSRange(location: line1.count, length: line2.count))
      attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size:14), range: NSRange(location: line1.count, length: line2.count))
      
      AlertView.show(message: attr) {
        let vc = ChangePwdController(type: .Reset,receiveEmail: self.recieveEmail,uuid: String(self.uuid))
        self.navigationController?.pushViewController(vc)
      }
      
      self.contentView.confirmButton.stopAnimation()
    }.catch { e in
      self.contentView.confirmButton.stopAnimation()
      print(e.asAPIError.errorInfo().message)
    }
  }
  
  
  func saveFindPasswordUUID() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .User, path: .saveFindPasswordUUID)
      let data = SOAPDictionary()
      data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
      data.set(key: "uuid", value: uuid)
      data.set(key: "status", value: "1")
      
      params.set(key: "params", value: data.result, type: .map(1))
      
      NetworkManager().request(params: params) { data in
        resolver.fulfill_()
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
      let params = SOAPParams(action: .Sms, path: .sendSmsForEmail)
      
      let data = SOAPDictionary()
      data.set(key: "title", value: "[Chien Chi Tow] Forgot Password")
      data.set(key: "email", value: self.recieveEmail)
      let usermodel = Defaults.shared.get(for: .userModel)
      let name = (usermodel?.first_name ?? "") + " " + (usermodel?.last_name ?? "")
      let url = APIHost().URL_API_UUID + self.uuid
      
      
      var message = "<p>Hi \(name),</p><p>We have received your request to reset your password for Chien Chi Tow App. Please follow the link below to reset your password:</p><p><a target=\"_blank\" href=\"" + url + "\"" + ">" +  url + "</a></p><p>If you have not requested to have your password reset, please ignore this email.</p><p>Thanks,</p><p>Chien Chi Tow</p>";
      message = message.replacingOccurrences(of: "&", with: "&amp;")
      message = message.replacingOccurrences(of: "<", with: "&lt;")
      message = message.replacingOccurrences(of: ">", with: "&gt;")
      data.set(key: "message", value: message)
     
      data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      data.set(key: "from_email", value: email)
      data.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "0")
      
      params.set(key: "params", value: data.result, type: .map(1))
      
      NetworkManager().request(params: params) { data in
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
}
