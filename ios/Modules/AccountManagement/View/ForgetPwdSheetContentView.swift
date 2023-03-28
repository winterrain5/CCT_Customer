//
//  ForgetPwdSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/25.
//

import UIKit
import IQKeyboardManagerSwift
import PromiseKit
@objcMembers
class ForgetPwdSheetView: UIView {
  var contentView = ForgetPwdSheetContentView.loadViewFromNib()
  let contentHeight:CGFloat = 400
  var scrolview = UIScrollView()
  var uuid = UUID().uuidString.prefix(6)
  var recieveEmail:String = ""
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    if !iPhoneX() {
      IQKeyboardManager.shared.keyboardDistanceFromTextField = 20
    }else {
      IQKeyboardManager.shared.keyboardDistanceFromTextField = 0
    }
    
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    contentView.confirmHandler = { [weak self] email in
      self?.recieveEmail = email
      guard let `self` = self else { return }
      self.contentView.confirmButton.startAnimation()
      firstly {
        self.getIdByEmail()
      }.then {
        self.saveFindPasswordUUID()
      }.then {
        self.getTSystemConfig()
      }.then { email in
        self.sendSmsForEmail(email)
      }.done {
        self.dismiss(complete: {
          let vc = ChangePwdController(type: .Reset,receiveEmail: self.recieveEmail,uuid: String(self.uuid))
          UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
        })
        self.contentView.confirmButton.stopAnimation()
      }.catch { e in
        self.contentView.confirmButton.stopAnimation()
        print(e.asAPIError.errorInfo().message)
        Toast.showError(withStatus: e.asAPIError.errorInfo().message)
      }
    }
    contentView.cancelHandler = { [weak self] in
      self?.dismiss()
    }
    

    scrolview.contentSize = CGSize(width: kScreenWidth, height: contentHeight)
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    scrolview.addGestureRecognizer(tap)
  }

  func getIdByEmail() -> Promise<Void> {
    Promise.init { resolver in
      
      if let clientId = Defaults.shared.get(for: .clientId),!clientId.isEmpty {
        resolver.fulfill_()
        return
      }
      
      if recieveEmail.isEmpty {
        resolver.reject(APIError.requestError(code: -1, message: "RecieveEmail can not be empty"))
        return
      }
      
      let params = SOAPParams(action: .Client, path: .getIdByEmail)
      params.set(key: "email", value: recieveEmail)
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
      params.set(key: "columns", value: "send_specific_email")
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
        Toast.showMessage("Please go to email to confirm the link")
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  @objc func tapAction(_ ges:UIGestureRecognizer) {
    let location = ges.location(in: scrolview)
    if location.y < (kScreenHeight - contentHeight) {
      dismiss()
    }
  }
  
  func dismiss(complete: (()->())? = nil) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.contentView.frame.origin.y = kScreenHeight
      self.backgroundColor = .clear
    } completion: { flag in
      complete?()
      self.removeFromSuperview()
    }
  }
  
  func show() {
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
      self.contentView.frame.origin.y = kScreenHeight - self.contentHeight
    } completion: { flag in
      
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    scrolview.frame = self.bounds
    contentView.size = CGSize(width: kScreenWidth, height: contentHeight)
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  
  static func show() {
    
    let spView = UIViewController.getTopVc()?.view
    
    let view = ForgetPwdSheetView()
    view.frame = spView?.bounds ?? .zero
    spView?.addSubview(view)
    
    spView?.addSubview(view)
    view.show()
    
  }
}

class ForgetPwdSheetContentView: UIView,UITextFieldDelegate {

  
  @IBOutlet weak var emailTf: UITextField!
  @IBOutlet weak var confirmButton: LoadingButton!
  var confirmHandler:((String)->())?
  var cancelHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    
    emailTf.returnKeyType = .done
    emailTf.delegate = self
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func confirmButtonAction(_ sender: Any) {
    confirmHandler?(emailTf.text ?? "")
  }
  
  @IBAction func concelButtonAction(_ sender: Any) {
    cancelHandler?()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }

}
