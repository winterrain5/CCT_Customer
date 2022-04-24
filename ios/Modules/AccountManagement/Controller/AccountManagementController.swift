//
//  AccountManagementController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit
import IQKeyboardManagerSwift
class AccountManagementController: BaseViewController {
  private var container = AccountManagementContainer.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.addSubview(container)
    container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getTClientPartInfo()
  }
  
  func getTClientPartInfo() {
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        self.container.model = model
        NotificationCenter.default.post(name: .nativeNotification, object: nil ,userInfo: ["type":"UserDataChanged"])
        Defaults.shared.set(model, for: .userModel)
      }
    } errorHandler: { e in
      
    }

  }
  
}
