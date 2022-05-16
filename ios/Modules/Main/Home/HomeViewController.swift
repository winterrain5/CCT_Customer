//
//  HomeViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/29.
//

import UIKit

class HomeViewController: BaseViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(menuDidClick(_:)), name: .menuDidOpenVc, object: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: nil, backButtonTitle: nil)
    
    getClientByUserId()
  }
  
  
  func refreshData() {
    
  }
  
  func getClientByUserId() {
    let params = SOAPParams(action: .Client, path: .getTClientByUserId)
    params.set(key: "userId", value: Defaults.shared.get(for: .userId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let id = try? JSON(data: data)["id"].rawString() {
        Defaults.shared.set(id, for: .clientId)
        self.getTClientPartInfo()
      }
    } errorHandler: { e in
      
    }
  }
  
  func getTClientPartInfo() {
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        Defaults.shared.set(model, for: .userModel)
        NotificationCenter.default.post(name: .menuInfoShouldChange, object: model)
      }
    } errorHandler: { e in
      
    }
  }
  
  @objc func menuDidClick(_ noti:Notification) {
    let selStr = noti.object as! String
    let sel = NSSelectorFromString(selStr)
    if self.responds(to: sel) {
      self.perform(sel)
    }
  }
  
}
