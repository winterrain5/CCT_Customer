//
//  TopUpCurrentCardController.swift
//  CCTIOS
//
//  Created by Derrick on 2023/8/22.
//

import UIKit
import PromiseKit
class TopUpCurrentCardController: BaseViewController {
  let cardView = WalletCardView.loadViewFromNib()
  let scrollView = UIScrollView()
  let topUpView = WalletTopupAmountView.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Top Up"
    
    view.addSubview(scrollView)
    scrollView.frame = self.view.bounds
    
    
    scrollView.addSubview(cardView)
    cardView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.width.equalTo(kScreenWidth)
      make.top.equalToSuperview().offset(20)
      make.height.equalTo(216)
    }
    
    let label = UILabel()
    label.text = "*Expiry Date Remains the Same\n*Enjoying current membership perks"
    label.numberOfLines = 0
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    scrollView.addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalTo(cardView.snp.bottom).offset(20)
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
    }
    
    scrollView.addSubview(topUpView)
    topUpView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.width.equalTo(kScreenWidth)
      make.top.equalTo(label.snp.bottom)
      make.height.equalTo(700)
    }
    
    firstly {
      self.getNewReCardAmount()
    }.then {
      self.getClientPartInfo()
    }.catch { e in
      print(e.asPKError.message)
    }
    
  }
  
  
  func getClientPartInfo() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
          self.cardView.model = model
          self.topUpView.userInfoModel = model
          
          self.scrollView.contentSize = CGSize(width: kScreenWidth, height: 1000 + kBottomsafeAreaMargin)
        }else {
          Toast.showError(withStatus: "decode UserModel Failed")
        }
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(PKError.some(e.localizedDescription))
      }
    }
   
  }
  
  func getNewReCardAmount() -> Promise<Void>{
    
    Promise.init { resolver in
      let params = SOAPParams(action: .Voucher, path: .getNewReCardAmountByClientId)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      NetworkManager().request(params: params) { data in
        self.cardView.money = String(data: data, encoding: .utf8)?.cgFloat()?.asLocaleCurrency ?? ""
        self.topUpView.currentBalance = String(data: data, encoding: .utf8)?.cgFloat() ?? 0
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(PKError.some(e.localizedDescription))
      }
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.topUpView.reloadPaymentMethod()
  }
  
  
}
