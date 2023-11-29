//
//  TopupOrPurchaseController.swift
//  CCTIOS
//
//  Created by Derrick on 2023/8/21.
//

import UIKit

class TopupOrPurchaseController: BaseViewController {
  
  var scrollView = UIScrollView()
 
  let cardView = WalletCardView.loadViewFromNib()
  let tierLabel = UILabel()
  let expireLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = "Chien Chi Tow"
    
    view.addSubview(scrollView)
    scrollView.frame = self.view.bounds
    
    let headLabel = UILabel()
    headLabel.text = "Current Membership"
    headLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    scrollView.addSubview(headLabel)
    headLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(20)
    }
    
    scrollView.addSubview(cardView)
    cardView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.width.equalTo(kScreenWidth)
      make.top.equalTo(headLabel.snp.bottom)
      make.height.equalTo(216)
    }
    
    scrollView.addSubview(tierLabel)
    tierLabel.text = "Membership Tier"
    tierLabel.textColor = .black
    tierLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
    tierLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalTo(cardView.snp.bottom)
    }
    
    
    scrollView.addSubview(expireLabel)
    expireLabel.text = "Expiry Date"
    expireLabel.textColor = .black
    expireLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
    expireLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalTo(tierLabel.snp.bottom).offset(2)
    }
    
    
  }
  
  func addOtherViews(_ count:Int) {
    let newCardBenefitLabel = UILabel()
    newCardBenefitLabel.text = "New Card Benefits"
    newCardBenefitLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    scrollView.addSubview(newCardBenefitLabel)
    
    if count > 0 {
      let topupButton = UIButton()
      scrollView.addSubview(topupButton)
      topupButton.titleForNormal = "Top Up"
      topupButton.titleColorForNormal = .white
      topupButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
      topupButton.backgroundColor = R.color.theamBlue()
      topupButton.cornerRadius = 8
      topupButton.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.top.equalTo(expireLabel.snp.bottom).offset(20)
        make.width.equalTo(200)
        make.height.equalTo(50)
      }
      topupButton.rx.tap.subscribe(onNext:{ [weak self] in
        let vc = TopUpCurrentCardController()
        self?.navigationController?.pushViewController(vc)
      }).disposed(by: rx.disposeBag)
      
      
       newCardBenefitLabel.snp.makeConstraints { make in
         make.left.equalToSuperview().offset(24)
         make.top.equalTo(topupButton.snp.bottom).offset(40)
       }
      
    } else {
      
       newCardBenefitLabel.snp.makeConstraints { make in
         make.left.equalToSuperview().offset(24)
         make.top.equalTo(expireLabel.snp.bottom).offset(40)
       }
    }
   
    
    let imgView = UIImageView(image: R.image.topup_chianchitow()!)
    imgView.backgroundColor =  .white
    imgView.contentMode = .scaleAspectFit
    scrollView.addSubview(imgView)
    imgView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(newCardBenefitLabel.snp.bottom).offset(20)
    }
    
    let newCardBenefitContentLabel = UILabel()
    newCardBenefitContentLabel.lineHeight = 18
    newCardBenefitContentLabel.text = "✔ New 12 months Expiry Date\n✔ Seamless Transfer of current credits\nto new card\n✔ Enjoy the New Card’s Benefits"
    newCardBenefitContentLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    newCardBenefitContentLabel.numberOfLines = 0
    scrollView.addSubview(newCardBenefitContentLabel)
    newCardBenefitContentLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().inset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(imgView.snp.bottom).offset(20)
    }
    
    
    let purchaseButton = UIButton()
    scrollView.addSubview(purchaseButton)
    purchaseButton.titleForNormal = "Purchase"
    purchaseButton.titleColorForNormal = .white
    purchaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
    purchaseButton.backgroundColor = R.color.theamBlue()
    purchaseButton.cornerRadius = 8
    purchaseButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(newCardBenefitContentLabel.snp.bottom).offset(20)
      make.width.equalTo(200)
      make.height.equalTo(50)
    }
    purchaseButton.rx.tap.subscribe(onNext:{ [weak self] in
      let vc = PurchaseNewCardController()
      self?.navigationController?.pushViewController(vc)
    }).disposed(by: rx.disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getClientPartInfo()
    getNewReCardAmount()
    getClientVoucherCount()
  }
  
  func getClientVoucherCount() {
    let params = SOAPParams(action: .Client, path: .getClientVoucherCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let count = String.init(data: data, encoding: .utf8)?.int {
        
        self.addOtherViews(count)
        
      } else {
        self.addOtherViews(1)
      }
      
    } errorHandler: { e in
    }
  }
  
  func getClientPartInfo() {
    
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        
        self.cardView.model = model
        
        let levelStr = model.new_recharge_card_level_text.split(separator: " ").first ?? "Basic"
        let attr1 = NSMutableAttributedString(string: "Membership Tier:\(levelStr)")
        attr1.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: NSRange(location: 16, length: levelStr.count))
        self.tierLabel.attributedText = attr1
        
        let cardExpireDate = model.new_recharge_card_period.date(withFormat: "yyyy-MM-dd")?.string(withFormat: "dd MMM yyyy") ?? ""
        let attr2 = NSMutableAttributedString(string: "Expiry Date:\(cardExpireDate)")
        attr2.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: NSRange(location: 12, length: cardExpireDate.count))
        self.expireLabel.attributedText = attr2
        
        self.scrollView.contentSize = CGSize(width: kScreenWidth, height: 820)
        
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
      self.cardView.money = String(data: data, encoding: .utf8)?.cgFloat()?.asLocaleCurrency ?? ""
    } errorHandler: { e in
      
    }
  }
  
  
}
