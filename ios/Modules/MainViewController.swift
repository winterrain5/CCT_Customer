//
//  MainViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/30.
//

import UIKit

class MainViewController: BaseViewController {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    NotificationCenter.default.addObserver(self, selector: #selector(recieveNotification), name: NSNotification.Name.openNativeVc, object: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @objc func recieveNotification() {
    let vc = OurServicesViewController()
    let nav = BaseNavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }

}
