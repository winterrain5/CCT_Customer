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
    let params = SOAPParams(action: .Company, path: .getParentCompanyBySysName)
    params.set(key: "systemName", value: "TCM")
    
    NetworkManager().request(params: params) { data in
      if let id = String(data: data, encoding: .utf8) {
        Defaults.shared.set(id, for: .companyId)
      }
    } errorHandler: { e in
      
    }

  }
  
  
}
