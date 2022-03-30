//
//  ViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/17.
//

import UIKit

class RNBridgeViewController: BaseViewController {
  var RNProperty:[AnyHashable:Any] = [:]
  var RNPageName:String = ""
  convenience init(RNPageName:String,RNProperty:[String:Any]) {
    self.init()
    
    self.RNProperty = RNProperty
    self.RNPageName = RNPageName
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    RNProperty["isNative"] = true
    ReactRootViewManager.shared().preLoadRootView(withName: RNPageName, initialProperty: RNProperty)
    let rootView = ReactRootViewManager.shared().rootView(withName: RNPageName)
    self.view = rootView;
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigation.bar.isHidden = true
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.navigation.bar.isHidden = false
  }
  
}
