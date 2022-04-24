//
//  ShopCheckOutFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/15.
//

import UIKit
import PromiseKit
class ShopCheckOutFooterView: UIView {
  
  @IBOutlet weak var selectCouponName: UILabel!
  
  @IBOutlet weak var walletTypeImg: UIImageView!
  @IBOutlet weak var walletTypeLabel: UILabel!
  @IBOutlet weak var walletNameLabel: UILabel!
  
  @IBOutlet weak var selectVoucherNameLabel: UILabel!
  
  @IBOutlet weak var collectionMethodLabel: UILabel!
  
  @IBOutlet weak var shipingAddressVHCons: NSLayoutConstraint!
  @IBOutlet weak var ShipingAddressContaier: UIView!
  @IBOutlet weak var potalCodeTf: UITextField!
  @IBOutlet weak var streetNameTf: UITextField!
  @IBOutlet weak var buildingNumTF: UITextField!
  @IBOutlet weak var unitNumTf: UITextField!
  @IBOutlet weak var cityTf: UITextField!
  
  
  @IBOutlet weak var totalItemLabel: UILabel!
  @IBOutlet weak var subTotalLabel: UILabel!
  @IBOutlet weak var couponLabel: UILabel!
  @IBOutlet weak var voucherLabel: UILabel!
  @IBOutlet weak var discountLabel: UILabel!
  @IBOutlet weak var deliveryFeeLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  
  
  @IBOutlet weak var couponVHCons: NSLayoutConstraint!
  @IBOutlet weak var voucherVCons: NSLayoutConstraint!
  @IBOutlet weak var discountVHCons: NSLayoutConstraint!
  @IBOutlet weak var deliveryFeeVHCons: NSLayoutConstraint!
  
  var selectCoupon:WalletCouponsModel?
  var selectVoucher:WalletVouchersModel?
  var selectPayMethod:MethodLines?
  var orderDetail:MyOrderDetailModel?
  
  /// 当前选择的支付类型，0：会员卡， 1 朋友的卡，2 信用卡
  var methodType = 0
  /// 会员卡购买优惠额度
  var discountPercent = "0"
  
  var orderId = ""
  override func awakeFromNib() {
    super.awakeFromNib()
    
    
    
  }
  
  func getCheckOutDetail() {
    let params = SOAPParams(action: .Sale, path: .getCheckoutDetails)
    params.set(key: "orderId", value: orderId)
    NetworkManager().request(params: params) { data in
      self.orderDetail = DecodeManager.decodeObjectByHandJSON(MyOrderDetailModel.self, from: data)
    } errorHandler: { e in
      
    }

  }
  
  func getClientInfo(_ isPayUser:Bool = true) {
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        self.potalCodeTf.text = model.post_code
        self.streetNameTf.text = model.street_name
        self.buildingNumTF.text = model.building_block_num
        self.unitNumTf.text = model.unit_num
        self.cityTf.text = model.city
        
      }
    } errorHandler: { e in
      
    }
    
  }
  
  /// 当前用户会员卡购买配套是否有折扣
  func getNewCardDiscountsByLevel(_ level:String) {
    if level.isEmpty {
      return
    }
  }
  
  var sub_total:CGFloat = 0
  var coupon_discount_total:CGFloat = 0
  var voucher_total:CGFloat = 0
  var delivery_total:CGFloat = 0
  var total:CGFloat = 0
  
  func setTotalVoucher() {
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  @IBAction func selectCouponButtonAction(_ sender: Any) {
    let vc = ShopSelectCouponOrVoucherController(selectType: 0)
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
    vc.selectCouponHandler = { [weak self] model in
      self?.selectCoupon = model
      self?.selectCouponName.text = model.name
    }
  }
  @IBAction func selectVoucherButtonAction(_ sender: Any) {
    let vc = ShopSelectCouponOrVoucherController(selectType: 1)
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
    vc.selectVoucherHandler = { [weak self] model in
      self?.selectVoucher = model
      self?.selectVoucherNameLabel.text = model.name
    }
  }
  @IBAction func collectionMethodButtonAction(_ sender: Any) {
  }
  
  @IBAction func payMethodButtonAction(_ sender: Any) {
    let vc = ShopPaymentMethodController()
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
    vc.selectCompleteHandler = {  [weak self] model in
      guard let `self` = self else { return }
      if model.type == 0 { // 自己的余额
        self.walletTypeImg.image = R.image.payment_card()
        self.walletTypeLabel.text = "CCT Wallet"
        self.walletNameLabel.text = model.amount.formatMoney().dolar
      }
      if model.type == 1 { // 自己的卡
        self.walletTypeImg.image = R.image.transaction_payment_other()
        self.walletNameLabel.text = model.name_on_card
        self.walletTypeLabel.text = "MasterCard"
      }
      if model.type == 2 { // 朋友的卡
        self.walletTypeImg.image = R.image.transaction_payment_other()
        self.walletTypeLabel.text = "Friends Card"
        self.walletNameLabel.text = model.name_on_card
      }
      
      
    }
  }
  
}
