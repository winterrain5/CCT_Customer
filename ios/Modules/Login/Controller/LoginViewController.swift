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
    content.scanQRCodeHandler = { [weak self] in
      self?.showScanVc()
    }
    getCompanyId()
  }
  
  func getCompanyId() {
    let params = SOAPParams(action: .SystemConfig, path: .getTConfig)

    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(SystemConfigModel.self, from: data) {
        Defaults.shared.set(model.company_id?.string ?? "97", for: .companyId)
        Defaults.shared.set(model.receive_specific_email ?? "", for: .recieveEmail)
        Defaults.shared.set(model.send_specific_email ?? "", for: .sendEmail)
      }
    } errorHandler: { e in
      
    }

  }
  
  func showScanVc() {
    var configuration = QRScannerConfiguration()
    configuration.title = ""
    configuration.hint = "Scan the Outlet QR Code"
    configuration.color = .white
    configuration.thickness = 2
    configuration.length = 44
    configuration.radius = 22
    configuration.readQRFromPhotos = false
    configuration.previewSize = CGSize(width: kScreenWidth - 48, height: kScreenWidth - 48)
    configuration.roundCornerSize = CGSize(width: kScreenWidth - 24, height: kScreenWidth - 24)
    
    let scanner = QRCodeScannerController(qrScannerConfiguration: configuration)
    scanner.delegate = self
    self.navigationController?.pushViewController(scanner, completion: nil)
  }
}

extension LoginViewController: QRScannerCodeDelegate {
    func qrScannerDidFail(_ controller: UIViewController, error: QRCodeError) {
        print("error:\(error.localizedDescription)")
    }
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        print("result:\(result)")
      
      let json = JSON(parseJSON: result)
      let locationName = json["name"].stringValue
      let id = json["id"].stringValue
//      let type = json["type"].stringValue
//
      let vc = EnterAccountController(isFromScanQRCode: true,outlet: (id:id,name:locationName))
      self.navigationController?.pushViewController(vc, completion: nil)
      Defaults.shared.set(true, for: .isLoginByScanQRCode)
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }
}

