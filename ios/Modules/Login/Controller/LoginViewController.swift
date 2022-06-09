//
//  LoginViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/28.
//

import UIKit

class LoginViewController: BaseViewController {
  
  var content = LoginContainer.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.bar.isHidden = true
    self.view.addSubview(content)
    content.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    
    getCompanyId()
  }
  
  func getCompanyId() {
    let params = SOAPParams(action: .SystemConfig, path: .getTConfig)

    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(SystemConfigModel.self, from: data) {
        Defaults.shared.set(model.company_id?.string ?? "", for: .companyId)
        Defaults.shared.set(model.receive_specific_email ?? "", for: .recieveEmail)
        Defaults.shared.set(model.send_specific_email ?? "", for: .sendEmail)
      }
    } errorHandler: { e in
      
    }

  }
  
  
}
