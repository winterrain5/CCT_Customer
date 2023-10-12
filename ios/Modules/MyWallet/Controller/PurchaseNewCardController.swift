//
//  PurchaseNewCardController.swift
//  CCTIOS
//
//  Created by Derrick on 2023/8/21.
//

import UIKit

class PurchaseNewCardController: BaseViewController {
  let scrollView = UIScrollView()
  let cardView = WalletCardView.loadViewFromNib()
  let purchaseView = WalletPurchaseNewcardAmounttContainer.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = "New Membership"
    
    
    view.addSubview(scrollView)
    scrollView.frame = self.view.bounds
    
    let headLabel = UILabel()
    headLabel.text = "Membership Tier"
    headLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    scrollView.addSubview(headLabel)
    headLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(20)
    }
    
    let platinum = createMemberShipTier(level: 1)
    scrollView.addSubview(platinum)
    platinum.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalTo(headLabel.snp.bottom).offset(20)
      make.height.equalTo(120)
    }
    
    let gold = createMemberShipTier(level: 2)
    scrollView.addSubview(gold)
    gold.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalTo(platinum.snp.bottom).offset(16)
      make.height.equalTo(120)
    }
    
    let silver = createMemberShipTier(level: 3)
    scrollView.addSubview(silver)
    silver.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.top.equalTo(gold.snp.bottom).offset(16)
      make.height.equalTo(120)
    }
    
    
    let currentLabel = UILabel()
    currentLabel.text = "Current Membership"
    currentLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    scrollView.addSubview(currentLabel)
    currentLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(silver.snp.bottom).offset(30)
    }
    
    scrollView.addSubview(cardView)
    cardView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.width.equalTo(kScreenWidth)
      make.top.equalTo(currentLabel.snp.bottom)
      make.height.equalTo(216)
    }

    scrollView.addSubview(purchaseView)
    purchaseView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.width.equalToSuperview()
      make.height.equalTo(420)
      make.top.equalTo(cardView.snp.bottom)
    }
    
    getClientPartInfo()
    getNewReCardAmount()
  }
  
  func createMemberShipTier(level:Int) -> UIView {
    var title = ""
    var tierContent = ""
    let imgView = UIImageView()
    switch level {
    case 1:
      title = "Platinum Membership"
      tierContent = "✔ Top Up $2,000 and above\n✔ 15% discount off services\n✔ 5% discount off products"
      imgView.image = R.image.platinum()
    case 2:
      title = "Gold Membership"
      tierContent = "✔ Top Up $1,000 and above\n✔ 10% discount off services\n✔ 5% discount off products"
      imgView.image = R.image.gold()
    case 3:
      title = "Silver Membership"
      tierContent = "✔ Top Up $500 and above\n✔ 5% discount off services\n✔ 5% discount off products"
      imgView.image = R.image.silver()
    default:
      break
    }
    let view = UIView()
    
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.textColor = .black
    titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
    }
    
    view.addSubview(imgView)
    imgView.contentMode = .scaleAspectFill
    imgView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(22)
      make.width.equalTo(160)
      make.height.equalTo(80)
      make.top.equalTo(titleLabel.snp.bottom).offset(12)
    }
    
    let tierContentLabel = UILabel()
    tierContentLabel.lineHeight = 16
    tierContentLabel.text = tierContent
    tierContentLabel.numberOfLines = 0
    tierContentLabel.textColor = .black
    tierContentLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    view.addSubview(tierContentLabel)
    tierContentLabel.snp.makeConstraints { make in
      make.left.equalTo(imgView.snp.right).offset(10)
      make.right.equalToSuperview().offset(-12)
      make.centerY.equalTo(imgView.snp.centerY)
    }
    
    
    return view
  }
  
  
  func getClientPartInfo() {
    
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        
        self.cardView.model = model
        self.scrollView.contentSize = CGSize(width: kScreenWidth, height: 1200)
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
      self.cardView.money =  String(data: data, encoding: .utf8)?.cgFloat()?.asLocaleCurrency ?? ""
      self.purchaseView.currentBalance = String(data: data, encoding: .utf8)?.cgFloat() ?? 0
    } errorHandler: { e in
      
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.purchaseView.reloadPaymentMethod()
  }

  
}
