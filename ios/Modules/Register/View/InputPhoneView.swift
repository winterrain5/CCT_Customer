//
//  InputPhoneView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/9.
//

import UIKit

class InputPhoneView: UIView,UITextFieldDelegate {
  
  @IBOutlet weak var sendOTPButton: LoadingButton!
  @IBOutlet weak var areaCodeTf: UILabel!
  @IBOutlet weak var phoneTf: UITextField!
  @IBOutlet weak var bottomLabel: TapLabel!
  var otpCode:String = ""
  override func awakeFromNib() {
    super.awakeFromNib()
    bottomLabel.enabledTapAction = true
    bottomLabel.enabledTapEffect = false
    
    bottomLabel.yb_addAttributeTapAction(["Terms of Service and conditions","Privacy Policy"]) { str, range, idx in
      if idx == 0 {
        WalletTermsConditionsSheetView.show()
      }
      if idx == 1 {
        DataProtectionSheetView.show()
      }
    }
    phoneTf.rx.text.changed.subscribe(onNext:{
      if $0?.isEmpty ?? false {
        self.sendOTPButton.isEnabled = false
        self.sendOTPButton.backgroundColor = R.color.grayE0()
      }else {
        self.sendOTPButton.isEnabled = true
        self.sendOTPButton.backgroundColor = R.color.theamRed()
      }
    }).disposed(by: rx.disposeBag)
  
    
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  @IBAction func sendOTPAction(_ sender: Any) {
    self.endEditing(true)
    getClientByPhone()
  }
  
  @IBAction func selectAreaCodeAction(_ sender: Any) {
    
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
 
  func getClientByPhone() {
    sendOTPButton.startAnimation()
    
    let params = SOAPParams(action: .Client, path: .getClientsByPhone)
    params.set(key: "mobile", value: phoneTf.text ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(UserModel.self, from: data) {
        if models.count == 0 { // 未注册
          self.sendSMSForMobile(nil)
        }
        if models.count == 1,let user = models.first { // 已注册
          // 判断是app 注册还是电脑端注册  电脑端注册 补全信息;手机端注册显示已经注册
          if user.source == "0" { // 电脑端
            Defaults.shared.set(user, for: .userModel)
            self.sendSMSForMobile(user)
          }else{
            self.showErrorAlert(errorType: 1)
          }
        }
        if models.count >= 2 {
          self.showErrorAlert(errorType: 0)
        }
        
      }
    } errorHandler: { e in
      self.sendOTPButton.stopAnimation()
      AlertView.show(message: "Failed to query system user！")
    }
    
  }
  
  func sendSMSForMobile(_ model:UserModel?) {
    let mobile = phoneTf.text?.trim() ?? ""
    let mapParams = SOAPParams(action: .Sms, path: .sendSmsForMobile)
    
    let params = SOAPDictionary()
    params.set(key: "title", value: "Sign in")
    params.set(key: "mobile", value: mobile)
    
    self.otpCode = Int.random(in: 1001...9999).string
    params.set(key: "message", value: "Your OTP is \(self.otpCode). Please enter the OTP within 2 minutes")
    params.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
    if let id = model?.id {
      params.set(key: "client_id", value: id)
    }
    
    
    mapParams.set(key: "params", value: params.result, type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      self.sendOTPButton.stopAnimation()
      
      let registInfo = RegistUserInfoModel()
      registInfo.mobile = mobile
      Defaults.shared.set(registInfo, for: .registModel)
      
      let vc = VerificationCodeController(type: .SignUp, source: mobile,otpCode:self.otpCode)
      UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
    } errorHandler: { e in
      self.sendOTPButton.stopAnimation()
      AlertView.show(message: "Failed to send SMS. Please try again later!")
    }

  }
  
  /// 0: 多个用户 1：手机端已注册
  func showErrorAlert(errorType:Int) {
    var title = ""
    var info = ""
    var confirm = ""
    if (errorType == 0){
      title = "You seem to have a duplicate mobile no."
      info = "Unable to proceed with registration, please approach our counter staff or call 62933933"
      confirm = "Call now"
    }else if (errorType == 1){
      title = "This mobile number is registered, please login with your login ID."
      info = ""
      confirm = "Login"
    }else if (errorType == 2){
      title = "You seem to have a wrong Identification No."
      info = "Unable to proceed with registration, please approach our counter staff or call 62933933"
      confirm = "Call now";
    }
    
    AlertView.show(title: title, message: info, leftButtonTitle: "Cancle", rightButtonTitle: confirm, messageAlignment: .center) {
      
    } rightHandler: {
      
      if errorType == 0 || errorType == 2 {
        CallUtil.call(with: "62933933")
      }else {
        let vc = EnterAccountController()
        UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
      }
      
    } dismissHandler: {
      
    }

  }
  
}
