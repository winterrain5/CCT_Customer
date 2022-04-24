//
//  FillInEnquiryFormContentView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/24.
//

import UIKit
import PromiseKit
class FillInEnquiryFormContentView: UIView,UITextFieldDelegate {

  @IBOutlet weak var nameTf: UITextField!
  @IBOutlet weak var mailTf: UITextField!
  @IBOutlet weak var subjectTf: UITextField!
  @IBOutlet weak var messageTf: UITextField!
  private var subjectID:String = ""
  var backHandler:(()->())?
  var submitHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    nameTf.isEnabled = false
    subjectTf.isEnabled = false
    mailTf.keyboardType = .emailAddress
    
    mailTf.delegate = self
    messageTf.delegate = self
    getUserModel()
  }
  
  func getUserModel() {
    if let userModel = Defaults.shared.get(for: .userModel) {
      self.nameTf.text = "\(userModel.first_name) \(userModel.last_name)"
      self.mailTf.text = userModel.email
    }else {
      let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
          Defaults.shared.set(model, for: .userModel)
          self.nameTf.text = "\(model.first_name) \(model.last_name)"
          self.mailTf.text = model.email
        }
      } errorHandler: { e in
        
      }
    }
  }

  @IBAction func selectSubjectButtonAction(_ sender: Any) {
    self.endEditing(true)
    FillInEnquiryFromSelectSubjectSheetView.showView { model in
      self.subjectTf.text = model.subject
      self.subjectID = model.id ?? ""
    }
  }
  @IBAction func submitAction(_ sender: LoadingButton) {
    sender.startAnimation()
    firstly {
      saveClientEnquiry()
    }.then { _ in
      self.getTSystemConfig()
    }.then { email in
      self.sendSmsForEmail(email)
    }.done { _ in
      sender.stopAnimation()
      self.submitHandler?()
    }.catch { e in
      sender.stopAnimation()
      Toast.showError(withStatus: e.asAPIError.errorInfo().message)
    }
    
  }
  @IBAction func backAction(_ sender: Any) {
    backHandler?()
  }
  
  func saveClientEnquiry() -> Promise<Void> {
    Promise.init { resolver in
      
      let email = self.mailTf.text ?? ""
      if email.isEmpty {
        Toast.showError(withStatus: "Email cannot be empty")
        return
      }
      if !email.isValidEmail {
        Toast.showError(withStatus: "email format is incorrect")
        return
      }
      
      if self.subjectTf.text?.isEmpty ?? false {
        Toast.showError(withStatus: "Subject cannot be empty")
        return
      }
      
      let message = self.messageTf.text ?? ""
      if message.isEmpty {
        Toast.showError(withStatus: "Message cannot be empty")
        return
      }
      
      let params = SOAPParams(action: .HelpManager, path: .saveClientEnquiry)
      
      let data = SOAPDictionary()
      data.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
      data.set(key: "client_submit_email", value: email)
      data.set(key: "subject_id", value: self.subjectID)
      data.set(key: "qa_content", value: message)
      
      params.set(key: "data", value: data, type: .map(1))
      
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
      params.set(key: "columns", value: "receive_specific_email")
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByCodable(SystemConfigModel.self, from: data) {
          resolver.fulfill(model.receive_specific_email ?? "")
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
      
      let content = SOAPDictionary()
      content.set(key: "title", value: "[Chien Chi Tow] Submit an enquiry")
      content.set(key: "email", value: email)
      content.set(key: "message", value: self.messageTf.text ?? "")
      content.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      content.set(key: "from_email", value: self.mailTf.text ?? "")
      content.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
      
      params.set(key: "params", value: content.result, type: .map(1))
      
      NetworkManager().request(params: params) { data in
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: "Send Email Failed"))
      }
      
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
}
