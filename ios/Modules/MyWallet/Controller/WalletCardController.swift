//
//  WalletCardController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/2.
//

import UIKit

class WalletCardController: BaseViewController {
  
  var container = WalletCardContainer.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(container)
    container.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapAction))
    container.addGestureRecognizer(tap)
  
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getClientPartInfo()
    getNewReCardAmount()
  }
  
  @objc func cardTapAction() {
    let vc = WalletDetailController()
    self.navigationController?.pushViewController(vc)
  }
  
  func getClientPartInfo() {
    
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeByCodable(UserModel.self, from: data) {
        
        self.container.model = model
      }else {
        Toast.showError(withStatus: "decode UserModel Failed")
      }
    } errorHandler: { e in
      
    }
  }
  
  func getNewReCardAmount() {
    
    let params = SOAPParams(action: .Voucher, path: .getNewReCardAmountByClientId)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      self.container.money = String(data: data, encoding: .utf8)?.formatMoney().dolar ?? ""
    } errorHandler: { e in
      
    }
  }
  
}
