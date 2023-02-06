//
//  ShopCheckOutFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/15.
//

import UIKit
import PromiseKit
import CryptoKit
import Stripe
class ShopCheckOutFooterView: UIView {
  let dateHMS = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
  let dateYMD = Date().string(withFormat: "yyyy-MM-dd")
  lazy var placeOrderBtn = LoadingButton().then { btn in
    btn.backgroundColor = R.color.theamRed()
    btn.cornerRadius = 22
    btn.titleForNormal = "Place Order"
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.addTarget(self, action: #selector(placeOrderAction), for: .touchUpInside)
  }
  lazy var bottomView = UIView().then { view in
    view.backgroundColor = .clear
    view.addSubview(placeOrderBtn)
    placeOrderBtn.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.height.equalTo(44)
      make.top.equalToSuperview().offset(16)
    }
    
  }
  
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
  
  
  @IBOutlet weak var couponTitleLabel: UILabel!
  @IBOutlet weak var totalItemLabel: UILabel!
  @IBOutlet weak var subTotalLabel: UILabel!
  @IBOutlet weak var couponLabel: UILabel!
  @IBOutlet weak var voucherLabel: UILabel!
  @IBOutlet weak var deliveryFeeLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var totalPriceContentView: UIView!
  @IBOutlet weak var totalHeadLabel: UILabel!
  
  @IBOutlet weak var couponContainer: UIView!
  @IBOutlet weak var voucherContainer: UIView!
  @IBOutlet weak var deliveryFeeContainer: UIView!
  
  @IBOutlet weak var couponVHCons: NSLayoutConstraint!
  @IBOutlet weak var voucherVCons: NSLayoutConstraint!
  @IBOutlet weak var deliveryFeeVHCons: NSLayoutConstraint!
  
  var updateContentHeight:((CGFloat)->())?
  
  var collectionMethodSheetView = ShopCollectionMethodSheetView.loadViewFromNib()
  
  var selectCoupon:WalletCouponsModel?
  var selectVoucher:WalletVouchersModel?
  var selectPayMethod:MethodLines?
  var payMethodCard:WalletPaymentMethodModel?
  var selectCollectionMethod:ShopCollectionModel?
  var localDeliveryMethod = ShopCollectionModel()
  var orderDetail:MyOrderDetailModel?
  var validNewVouchers:[ValidNewVoucherModel] = []
  
  var staff:BusinessManModel?
  var pointPresentMultiple:CGFloat = 0
  
  /// 当前选择的支付类型，0：会员卡， 1 朋友的卡，2 信用卡
  var methodType = 0
  /// 会员卡余额
  var userBalance:CGFloat = 0
  /// 会员卡购买优惠额度
  var discountPercent:CGFloat = 0
  var clientSecret = ""
  
  var orderId = "" {
    didSet {
      getCheckOutDetail()
    }
  }
  
  let itemH:CGFloat = 40
  override func awakeFromNib() {
    super.awakeFromNib()
    
    addFooterView()
    let window = UIApplication.shared.keyWindow
    window?.addSubview(bottomView)
    bottomView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(bottomSheetHeight)
    }
    
    getClientInfo()
    getUserAmount()
  }
  
  func addFooterView() {
    bottomView.alpha = 1
  }
  
  func removeFooterView() {
    bottomView.alpha = 0
  }
  
  func getCheckOutDetail() {
    let params = SOAPParams(action: .Sale, path: .getCheckoutDetails)
    params.set(key: "orderId", value: orderId)
    NetworkManager().request(params: params) { data in
      self.orderDetail = DecodeManager.decodeObjectByHandJSON(MyOrderDetailModel.self, from: data)
      self.getDefaultDelivery()
    } errorHandler: { e in
      
    }
  }
  
  
  func getClientInfo(_ isPayUser:Bool = true) {
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        Defaults.shared.set(model, for: .userModel)
        
        self.potalCodeTf.text = model.post_code
        self.streetNameTf.text = model.street_name
        self.buildingNumTF.text = model.building_block_num
        self.unitNumTf.text = model.unit_num
        self.cityTf.text = model.city
        
        self.getNewCardDiscountsByLevel(model.new_recharge_card_level)
      }
    } errorHandler: { e in
      
    }
    
  }
  
  /// 获取余额
  func getUserAmount() {
    let params = SOAPParams(action: .Voucher, path: .getNewReCardAmountByClientId)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      let banlance = (String(data: data, encoding: .utf8) ?? "")
      self.walletNameLabel.text = banlance.formatMoney().dolar
      self.userBalance = banlance.formatMoney().cgFloat() ?? 0
      self.methodType = 0
    } errorHandler: { e in
      
    }
  }
  
  /// 当前用户会员卡购买配套是否有折扣
  func getNewCardDiscountsByLevel(_ level:String) {
    if level.isEmpty {
      return
    }
    
    let params = SOAPParams(action: .VipDefinition, path: .getNewCardDiscountsByLevel)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "cardLevel", value: level)
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(CardPrivilegesModel.self, from: data) {
        self.discountPercent = models.filter({ $0.sale_category == "P" }).first?.discount_percent?.cgFloat() ?? 0
        self.updateViewData()
      }
    } errorHandler: { e in
      
    }
    
  }
  
  // 获取默认的运费
  func getDefaultDelivery() {
    let params = SOAPParams(action: .SystemConfig, path: .getTSystemConfig)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(SystemConfigModel.self, from: data) {
        
        self.localDeliveryMethod.id = "-1"
        let subtotal = self.orderDetail?.Order_Info?.subtotal?.cgFloat() ?? 0
        var localDeliveryText = ""
        if subtotal >= 150 {
          self.localDeliveryMethod.delivery_fee = "0"
          localDeliveryText = "Local Delivery $0"
        }else {
          self.localDeliveryMethod.delivery_fee = model.delivery_fee ?? ""
          localDeliveryText = "Local Delivery \(model.delivery_fee?.formatMoney().dolar ?? "")"
        }
        self.localDeliveryMethod.text = localDeliveryText
        self.selectCollectionMethod = self.localDeliveryMethod
        
        self.collectionMethodSheetView.localDeliveryMethod = self.localDeliveryMethod
        self.collectionMethodLabel.text = localDeliveryText
        
        self.updateViewData()
      }
    } errorHandler: { e in
      
    }
    
  }
  
  var sub_total:CGFloat = 0
  var coupon_discount_total:CGFloat = 0
  var voucher_total:CGFloat = 0
  var delivery_total:CGFloat = 0
  var total_pay:CGFloat = 0
  
  func updateViewData() {
    
    sub_total = 0
    coupon_discount_total = 0
    voucher_total = 0
    delivery_total = 0
    total_pay = 0
    
    sub_total = orderDetail?.Order_Info?.subtotal?.cgFloat() ?? 0
    
    // coupon
    if selectCoupon == nil { // 没有选择折扣券
      let discount = discountPercent / 100
      if methodType == 0 || methodType == 1 { // 自己的充值卡 朋友的卡 享受会员优惠
        coupon_discount_total = sub_total * discount
      }
      couponTitleLabel.text = "Discount"
    }else {
      // 使用了折扣券就不享受会员卡优惠了
      if selectCoupon?.value_type == "1" {
        let discount = selectCoupon?.nominal_value?.cgFloat() ?? 0
        coupon_discount_total = sub_total * discount
      }else {
        coupon_discount_total = selectCoupon?.nominal_value?.cgFloat() ?? 0
      }
      couponTitleLabel.text = "Voucher"
    }
    
    if coupon_discount_total == 0 {
      couponVHCons.constant = 0
      couponContainer.isHidden = true
    }else {
      couponVHCons.constant = itemH
      couponContainer.isHidden = false
    }
    couponLabel.text = "-" + coupon_discount_total.string.formatMoney().dolar
    
    // 礼券
    if selectVoucher == nil {
      voucher_total = 0
      voucherVCons.constant = 0
      voucherContainer.isHidden = true
    }else {
      voucher_total = selectVoucher?.balance?.cgFloat() ?? 0
      voucherVCons.constant = 40
      voucherContainer.isHidden = false
      voucherLabel.text = "-" + voucher_total.string.formatMoney().dolar
    }
    
    // 运费
    if self.selectCollectionMethod?.id == "-1" {
      delivery_total = self.selectCollectionMethod?.delivery_fee.cgFloat() ?? 0
      if delivery_total == 0 {
        deliveryFeeVHCons.constant = 0
        deliveryFeeContainer.isHidden = true
      }else {
        deliveryFeeVHCons.constant = itemH
        deliveryFeeContainer.isHidden = false
      }
      shipingAddressVHCons.constant = 363
      ShipingAddressContaier.isHidden = false
      
    }else {
      delivery_total = 0
      deliveryFeeVHCons.constant = 0
      shipingAddressVHCons.constant = 0
      ShipingAddressContaier.isHidden = true
      deliveryFeeContainer.isHidden = true
      
    }
    // 金额大于150 免运费
    if sub_total >= 150 {
      delivery_total = 0
    }
    
    if sub_total - coupon_discount_total - voucher_total < 0 {
      total_pay = delivery_total
    }else {
      total_pay = sub_total - coupon_discount_total - voucher_total + delivery_total
    }
    
    deliveryFeeLabel.text = delivery_total.string.formatMoney().dolar
    subTotalLabel.text = sub_total.string.formatMoney().dolar
    totalLabel.text = total_pay.string.formatMoney().dolar
    totalItemLabel.text = orderDetail?.Order_Line_Info?.reduce(0, { $0 + ($1.qty?.cgFloat() ?? 0) }).string
    let gst = orderDetail?.Order_Line_Info?.reduce(0, { $0 + ($1.tax?.float() ?? 0) }) ?? 0
    if methodType != 2 {
      totalHeadLabel.text = "Total"
    }else {
      totalHeadLabel.text = gst > 0 ? "Total(Inclusive of GST \(gst.string.formatMoney().dolar))" : "Total"
    }
    
    self.setNeedsUpdateConstraints()
    self.layoutIfNeeded()
    self.updateContentHeight?(self.totalPriceContentView.frame.maxY + 40)
   
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  @IBAction func selectCouponButtonAction(_ sender: Any) {
    let vc = ShopSelectCouponOrVoucherController(selectType: 0,selectCoupon: selectCoupon)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
    vc.selectCouponHandler = { [weak self] model in
      guard let model = model else {
        self?.selectCouponName.text = "Not Selected"
        self?.couponTitleLabel.text = "Discount"
        self?.selectCoupon = nil
        self?.updateViewData()
        return
      }
      self?.selectCoupon = model
      self?.selectCouponName.text = model.name
      self?.updateViewData()
    }
  }
  @IBAction func selectVoucherButtonAction(_ sender: Any) {
    let vc = ShopSelectCouponOrVoucherController(selectType: 1,selectVoucher: selectVoucher)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
    vc.selectVoucherHandler = { [weak self] model in
      guard let model = model else {
        self?.selectVoucherNameLabel.text = "Not Selected"
        self?.selectVoucher = nil
        self?.updateViewData()
        return
      }
      self?.selectVoucher = model
      self?.selectVoucherNameLabel.text = model.name
      self?.updateViewData()
    }
  }
  @IBAction func collectionMethodButtonAction(_ sender: Any) {
    collectionMethodSheetView.show { [weak self] model in
      if model.id == "-1" {
        self?.collectionMethodLabel.text = model.text
      }else {
        self?.collectionMethodLabel.text = "Self-Collection @ \(model.text)"
      }
      
      self?.selectCollectionMethod = model
      self?.updateViewData()
    }
  }
  
  @IBAction func payMethodButtonAction(_ sender: Any) {
    let vc = ShopPaymentMethodController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
    vc.selectCompleteHandler = {  [weak self] model,card in
      guard let `self` = self else { return }
      self.payMethodCard = card
      self.selectPayMethod = model
      if model.type == 0 { // 自己的余额
        self.walletTypeImg.image = R.image.payment_card()
        self.walletTypeLabel.text = "CCT Wallet"
        self.walletNameLabel.text = model.amount.formatMoney().dolar
      }
      if model.type == 1 { // 朋友的卡
        self.walletTypeImg.image = R.image.transaction_payment_other()
        self.walletTypeLabel.text = "Friends Card"
        self.walletNameLabel.text = model.name_on_card
      }
      if model.type == 2 { // 自己的卡
        self.walletTypeImg.image = R.image.transaction_payment_other()
        self.walletNameLabel.text = model.name_on_card
        self.walletTypeLabel.text = "MasterCard"
      }
      
      self.methodType = model.type
      self.updateViewData()
    }
  }
  
  @objc func placeOrderAction() {
    
    if !judgeShippingAddress() {
      return
    }
    if !judgeAmountCanPay() {
      return
    }
    if methodType == 1 {
      getFriendPayPwd()
    }else {
      showUserPasswordSheet()
    }
  }
  
  
  func judgeAmountCanPay() -> Bool{
    if methodType == 0 {
      if userBalance < total_pay {
        Toast.showMessage("Current balance is insufficient")
        return false
      }
    }
    if methodType == 1 {
      var banlance = selectPayMethod?.amount.cgFloat() ?? 0
      let transLimit = selectPayMethod?.trans_limit.cgFloat() ?? 0
      if transLimit > 0 {
        banlance = transLimit
      }
      if banlance < total_pay {
        Toast.showMessage("Current balance is insufficient")
        return false
      }
    }
    return true
  }
  
  func judgeShippingAddress() -> Bool{
    
    if selectCollectionMethod?.id != "-1" {
      return true
    }
    
    let postalCode = potalCodeTf.text ?? ""
    if postalCode.isEmpty {
      Toast.showMessage("Please fill in the Postal Code")
      return false
    }
    
    let start = postalCode.slicing(from: 0, length: 2)
    if postalCode.count != 6 || (start?.int ?? 0) > 82 {
      Toast.showMessage("Postal Code entered is invalid")
      return false
    }
    
    if streetNameTf.text?.isEmpty ?? false {
      Toast.showMessage("Please fill in the Street Name")
      return false
    }
    
    if buildingNumTF.text?.isEmpty ?? false {
      Toast.showMessage("Please fill in the Building/Block Number")
      return false
    }
    
    return true
  }
  
  // 获取朋友的支付密码
  func getFriendPayPwd() {
    let params = SOAPParams(action: .Client, path: .getClientPayPd)
    params.set(key: "clientId", value: selectPayMethod?.card_owner_id ?? "")
#if DEBUG
    Toast.showLoading(withStatus: params.path)
#endif
    NetworkManager().request(params: params) { data in
      let pwd = (String(data: data, encoding: .utf8) ?? "")
      if !pwd.isEmpty {
        self.showFriendPasswordSheet(pwd)
      }else {
        Toast.showMessage("The current user has not set a payment password. Please confirm and pay！")
      }
    } errorHandler: { _ in
      
    }
    
  }
  
  func showUserPasswordSheet() {
    removeFooterView()
    let pwd = Defaults.shared.get(for: .userModel)?.pay_password ?? ""
    CardDigitPinView.showView(pin: pwd) { pwd in
      self.addFooterView()
      self.getBusiness()
    } cancleHandler: {
      self.addFooterView()
    }
  }
  
  func showFriendPasswordSheet(_ pwd:String) {
    removeFooterView()
    CardDigitPinView.showView(pin: pwd) { pwd in
      self.addFooterView()
      self.getBusiness()
    } cancleHandler: {
      self.addFooterView()
    }
  }
  
  func getBusiness() {
    let params = SOAPParams(action: .Employee, path: .getBusiness)
#if DEBUG
    Toast.showLoading(withStatus: params.path)
#endif
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(BusinessManModel.self, from: data) {
        self.staff = model
        // 信用卡支付
        if self.methodType == 2 {
          //获取等级进行积分计算
          self.getClientVipLevel()
        }else{
          // 余额支付
          self.getValidNewVouchers()
        }
      }
    } errorHandler: { e in
      
    }
    
  }
  
  func getValidNewVouchers() {
    let params = SOAPParams(action: .ClientProfile, path: .getValidNewVouchers)
    if methodType == 0 {
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    }else {
      params.set(key: "clientId", value: selectPayMethod?.card_owner_id ?? "")
    }
#if DEBUG
    Toast.showLoading(withStatus: params.path)
#endif
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ValidNewVoucherModel.self, from: data) {
        self.validNewVouchers = models
        self.payTOrder()
      }
    } errorHandler: { e in
      
    }
    
  }
  
  func getClientVipLevel() {
    let params = SOAPParams(action: .Sale, path: .getClientVipLevel)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
#if DEBUG
    Toast.showLoading(withStatus: params.path)
#endif
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(ClientVipLevelModel.self, from: data) {
        self.pointPresentMultiple = model.point_present_multiple?.cgFloat() ?? 0
        self.createInstance()
      }
    } errorHandler: { e in
      
    }
    
  }
  
  func createInstance() {
    let params = SOAPParams(action: .StripePayment, path: .createInstance)
    
    let data = SOAPDictionary()
    data.set(key: "totalAmount", value: total_pay * 100)
    data.set(key: "email", value: Defaults.shared.get(for: .userModel)?.email ?? "")
    data.set(key: "invoice_no", value: orderDetail?.Order_Info?.invoice_no ?? "")
    data.set(key: "orderId", value: orderId)
    
    params.set(key: "data", value: data.result,type: .map(1))
#if DEBUG
    Toast.showLoading(withStatus: params.path)
#endif
    NetworkManager().request(params: params) { data in
      if let secret = JSON.init(from: data)?["clientSecret"].stringValue,!secret.isEmpty {
        self.clientSecret = secret
        
      }
    } errorHandler: { e in
      
    }
  }
  
  func startPay() {
    let model = self.selectPayMethod
    let card = STPPaymentMethodCardParams()
    card.cvc = model?.authorisation_code ?? ""
    if let date = model?.expiry_date?.date(withFormat: "yyyy-MM-dd") {
      card.expYear = NSNumber.init(value: date.year.uInt)
      card.expMonth =  NSNumber.init(value: date.month.uInt)
    }
    card.number = model?.card_number
    let params = STPPaymentMethodParams(card: card, billingDetails: nil, metadata: nil)
    
    let intent = STPPaymentIntentParams(clientSecret: self.clientSecret)
    intent.paymentMethodParams = params
    
#if DEBUG
    Toast.showLoading(withStatus: "Stripe SDK ConfirmPayment")
#endif
    STPAPIClient().confirmPaymentIntent(with: intent) { result, e in
      if e != nil {
        Toast.showMessage("Credit card payment failed")
      }else {
        self.payTOrder()
      }
    }
  }
  
  func payTOrder() {
    
    let mapParams = SOAPParams(action: .Sale, path: .payTOrder)
    
    let data = SOAPDictionary()
    
    //                ['id' => 传订单的id
    //                'date' => 当前的日期,
    //                'total_recharge_discount' => 如果是会员卡打折，传打折额度；否则传0,
    //                 ’reward_id‘=>如果是用reward打折，传reward的id,
    //                ‘reward_amout’=>如果是用reward打折，传reward的折扣额度,
    //                'paid_amount' =>如果是会员卡付款，传0；信用卡付款传实际支付额度,
    //                'origin_paid_amount' => 如果是会员卡付款，传0；信用卡付款传应该支付额度,
    //                'gift_voucher_amount' => 默认传0,
    //                'new_gift_voucher_amount' =>如果是会员卡付款，传实际付款额度；如果是信用卡支付，传0,
    //                'voucher_amount' =>  默认传0,
    //                'pay_by_balance' =>  默认传0,
    //                'pay_by_gift' =>  默认传0,
    //                'pay_by_service' =>  默认传0,
    //                'change' => 默认0,
    //                ‘freight’=>如果是快递方式，传运费;如果是自取，传0,
    //                'saleman_id' =>传默认员工id,
    //                'balance' => 默认传0,
    //                'remark' =>传空’‘,
    //                 'present_points' =>如果是会员卡付款，传0；如果是信用卡付款，根据上面计算得到积分,
    //                  ’collection_method‘=>自取传1，快递传2,
    //                  ‘post_code’=>快递方式，传邮政编码；否则传空,
    //                 ‘city’=>快递方式，传city字段；否则传空,
    //                  ‘street_name’=>快递方式，传street name字段；否则传空,
    //                  ‘building_block_num’=>快递方式，传building block num字段；否则传空,
    //                  ‘unit_num’=>快递方式，传unit num字段；否则传空,
    //                 ‘address’=>快递方式，按照设计图上把地址右边拼起来；否则就传空,
    //                'invoice_date' => 当前日期’yyyy-MM-dd‘,
    //        'due_date' => 当前日期’yyyy-MM-dd‘,
    //        'close_time' => 当前时间 'yyyy-MM-dd HH:mm:ss',
    //                'status' => 默认传1,
    //‘is_from_app’=1]
    
    let Order_Info = SOAPDictionary()
    Order_Info.set(key: "id", value: orderDetail?.Order_Info?.id ?? "")
    Order_Info.set(key: "date", value: dateYMD)
    
    if selectCoupon == nil && (methodType == 0 || methodType == 1) { // 使用会员折扣
      Order_Info.set(key: "total_recharge_discount", value: coupon_discount_total)
    }else {
      Order_Info.set(key: "total_recharge_discount", value: 0)
    }
    
    if selectCoupon != nil { // 使用了优惠券
      Order_Info.set(key: "reward_id", value: selectCoupon?.id ?? "")
      Order_Info.set(key: "reward_amout", value: coupon_discount_total)
    }
    
    if selectVoucher != nil {
      Order_Info.set(key: "gift_id", value: selectVoucher?.id ?? "")
      Order_Info.set(key: "gift_amout", value: voucher_total)
    }
    
    if methodType == 0 || methodType == 1 { // 会员卡支付
      Order_Info.set(key: "paid_amount", value: 0)
      Order_Info.set(key: "origin_paid_amount", value: 0)
      Order_Info.set(key: "new_gift_voucher_amount", value: total_pay)
    }else { // 信用卡支付
      Order_Info.set(key: "paid_amount", value: total_pay)
      Order_Info.set(key: "origin_paid_amount", value: total_pay)
      Order_Info.set(key: "new_gift_voucher_amount", value: 0)
    }
    Order_Info.set(key: "gift_voucher_amount", value: 0)
    
    Order_Info.set(key: "voucher_amount", value: 0)
    Order_Info.set(key: "pay_by_balance", value: 0)
    Order_Info.set(key: "pay_by_gift", value: voucher_total)
    Order_Info.set(key: "pay_by_service", value: 0)
    Order_Info.set(key: "change", value: 0)
    
    // 积分
    var presentPoints:CGFloat = 0
    if selectCollectionMethod?.id == "-1" && delivery_total > 0 {
      Order_Info.set(key: "freight", value: delivery_total)
      presentPoints = total_pay - delivery_total
    }else {
      Order_Info.set(key: "freight", value: 0)
      presentPoints = total_pay
    }
    
    Order_Info.set(key: "saleman_id", value: staff?.id ?? "")
    Order_Info.set(key: "balance", value: 0)
    Order_Info.set(key: "remark", value: "")
    
    if let birthDay = Defaults.shared.get(for: .userModel)?.birthday.date(withFormat: "yyyy-MM-dd") {
      if birthDay.isInCurrentMonth && birthDay.isInToday {
        presentPoints *= 2
      }
    }
    presentPoints *= pointPresentMultiple
    Order_Info.set(key: "present_points", value: presentPoints)
    
    if selectCollectionMethod?.id == "-1" {
      let postCode = potalCodeTf.text ?? ""
      let city = cityTf.text ?? ""
      let street = streetNameTf.text ?? ""
      let buildNum = buildingNumTF.text ?? ""
      let unitNum = unitNumTf.text ?? ""
      let address = street + " " + buildNum + " " + unitNum + " " + city + " " + postCode
      Order_Info.set(key: "collection_method", value: 2)
      Order_Info.set(key: "post_code", value: postCode)
      Order_Info.set(key: "city", value: city)
      Order_Info.set(key: "street_name", value: street)
      Order_Info.set(key: "building_block_num", value: buildNum)
      Order_Info.set(key: "unit_num", value: unitNum)
      Order_Info.set(key: "address", value: address)
    }else {
      Order_Info.set(key: "collection_method", value: 1)
      Order_Info.set(key: "post_code", value: "")
      Order_Info.set(key: "city", value: "")
      Order_Info.set(key: "street_name", value: "")
      Order_Info.set(key: "building_block_num", value: "")
      Order_Info.set(key: "unit_num", value: "")
      Order_Info.set(key: "address", value: "")
    }
    
    Order_Info.set(key: "invoice_date", value: dateYMD)
    Order_Info.set(key: "due_date", value: dateYMD)
    Order_Info.set(key: "close_time", value: dateHMS)
    Order_Info.set(key: "status", value: 1)
    Order_Info.set(key: "is_from_app", value: 1)
    
    //朋友的卡付款
    if methodType == 1 {
      Order_Info.set(key: "friend_pay", value: 1)
      Order_Info.set(key: "card_owner_id", value: selectPayMethod?.card_owner_id ?? "")
      Order_Info.set(key: "price", value: sub_total)
      Order_Info.set(key: "total_price", value: total_pay)
    }
    
    data.set(key: "Order_Info", value: Order_Info.result, keyType: .string, valueType: .map(1))
    
    
    //        >[
    //‘data’=>[
    //        'id' => 明细的id,
    //                'salesmen_id' =>传默认员工id,
    //                'has_paid' => 1,
    //                'pay_by_balance' =>默认传0,
    //‘pay_by_voucher’=>如果是会员卡付款，传付款额度；如果是信用卡付款，传0,
    //‘pay_by_gift’=>默认传0,
    //‘pay_by_service’=>默认传0,
    //‘new_recharge_discount’=>如果是会员卡付款，传折扣额度；如果是信用卡付款，传0
    //]
    
    let Order_Lines = SOAPDictionary()
    
    var map:[String:[SOAPDictionary]] = [:]
    
    if (methodType == 0 || methodType == 1) && validNewVouchers.count > 0 {
      guard let order_line_info = orderDetail?.Order_Line_Info else { return }
      for e in order_line_info {
        var line_total:CGFloat = 0
        let order_pay = e.total?.cgFloat() ?? 0
        if selectCoupon == nil {
          
          if discountPercent > 0 {
            line_total = order_pay * (1 - discountPercent / 100)
          }else {
            line_total = e.price?.cgFloat() ?? 0
          }
          let total_all = orderDetail?.Order_Info?.total?.cgFloat() ?? 0
          line_total = line_total - (voucher_total * (order_pay / total_all))
          
        }else {
          
          let nominal_value = selectCoupon?.nominal_value?.cgFloat() ?? 0
          if selectCoupon?.value_type == "1" {
            line_total = order_pay * (1 - nominal_value)
          }else {
            let count = orderDetail?.Order_Line_Info?.count ?? 0
            line_total = order_pay - ( nominal_value / CGFloat(count) )
          }
          let total_all = orderDetail?.Order_Info?.subtotal?.cgFloat() ?? 0
          line_total = line_total - (voucher_total * (order_pay / total_all))
          
        }
        
        var pay_voucher:[SOAPDictionary] = []
        if line_total > 0 {
          for e in validNewVouchers {
            let balance = e.balance.cgFloat() ?? 0
            
            if balance == 0 { continue }
            
            let pay_voucher_item = SOAPDictionary()
            
            pay_voucher_item.set(key: "bought_voucher_id", value: e.id)
            if line_total >= balance {
              pay_voucher_item.set(key: "paid_amount", value: balance)
              line_total -= balance
              e.balance = "0"
            }else {
              pay_voucher_item.set(key: "paid_amount", value: line_total)
              e.balance = (balance  - line_total).string
              line_total = 0
            }
            pay_voucher_item.set(key: "voucher_type", value: e.voucher_type)
            pay_voucher_item.set(key: "create_date", value: dateHMS)
            pay_voucher_item.set(key: "is_present", value: 0)
            
            pay_voucher.append(pay_voucher_item)
            
            if line_total == 0 { break }
          }
        }
        
        map[e.id ?? ""] = pay_voucher
      }
     
    }
    
    orderDetail?.Order_Line_Info?.enumerated().forEach({ i,e in
      
      let e_total = e.total?.cgFloat() ?? 0
      
      let Order_Lines_0 = SOAPDictionary()
      let Order_Lines_Item = SOAPDictionary()
      
      Order_Lines_Item.set(key: "id", value: e.id ?? "")
      Order_Lines_Item.set(key: "salesmen_id", value: staff?.id ?? "")
      Order_Lines_Item.set(key: "has_paid", value: 1)
      Order_Lines_Item.set(key: "pay_by_balance", value: 0)
      
      var reward_discount:CGFloat = 0
      let total_all = orderDetail?.Order_Info?.subtotal?.cgFloat() ?? 0
      if methodType == 0 || methodType == 1 { // 会员卡支付
        var pay_by_voucher:CGFloat = 0
        var new_recharge_discount:CGFloat = 0
        if selectCoupon != nil { // 优惠券
          let nominal_value = selectCoupon?.nominal_value?.cgFloat() ?? 0
          if selectCoupon?.value_type == "1" {
            
            reward_discount = e_total * nominal_value
            pay_by_voucher =  e_total - reward_discount
            
          }else {
            
            reward_discount = nominal_value * ( e_total / total_all )
            pay_by_voucher = e_total - reward_discount
            
          }
        }else { // 会员折扣
          if discountPercent > 0 {
            
            new_recharge_discount = e_total * (discountPercent / 100)
            pay_by_voucher = e_total - new_recharge_discount
            reward_discount = 0
            
          }
        }
        
        Order_Lines_Item.set(key: "pay_by_voucher", value: pay_by_voucher)
        Order_Lines_Item.set(key: "new_recharge_discount", value: new_recharge_discount)
        
      } else { // 信用卡支付
        
        if selectCoupon == nil {
          Order_Lines_Item.set(key: "reward_discount", value: reward_discount)
        } else {
          let nominal_value = selectCoupon?.nominal_value?.cgFloat() ?? 0
          if selectCoupon?.value_type == "1" {
            reward_discount = e_total * nominal_value
          }else {
            reward_discount = nominal_value * ( e_total / total_all )
          }
        }
        Order_Lines_Item.set(key: "pay_by_voucher", value: 0)
        Order_Lines_Item.set(key: "new_recharge_discount", value: 0)
      }
      
      let pay_by_gift = voucher_total * (e_total / total_all)
      Order_Lines_Item.set(key: "pay_by_gift", value: pay_by_gift)
      Order_Lines_Item.set(key: "pay_by_service", value: 0)
      Order_Lines_Item.set(key: "reward_discount", value: reward_discount)
      
      if selectCollectionMethod?.id == "-1" {
        Order_Lines_Item.set(key: "collection_method", value: 2)
        Order_Lines_Item.set(key: "delivery_location_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      }else {
        Order_Lines_Item.set(key: "collection_method", value: 1)
        Order_Lines_Item.set(key: "delivery_location_id", value: selectCollectionMethod?.id ?? "")
      }
      
      Order_Lines_Item.set(key: "has_delivered", value: 0)
      Order_Lines_Item.set(key: "delivery_time", value: "")
      
      Order_Lines_0.set(key: "data", value: Order_Lines_Item.result, keyType: .string, valueType: .map(1))
      
      let Pay_Voucher = SOAPDictionary()
      let pays = map[e.id ?? ""]
      if pays != nil {
        pays?.enumerated().forEach({ i,e in
          Pay_Voucher.set(key: i.string, value: e.result,keyType: .string,valueType: .map(1))
        })
      }
      
      Order_Lines_0.set(key: "Pay_Voucher", value: Pay_Voucher.result,keyType: .string,valueType: .map(1))
      
      Order_Lines.set(key: i.string, value: Order_Lines_0.result,keyType: .string,valueType: .map(1))
      
    })
    
    data.set(key: "Order_Lines", value: Order_Lines.result,keyType: .string,valueType: .map(1))
    
    let payMethods = SOAPDictionary()
    let payMethods_0 = SOAPDictionary()
    
    if methodType == 2 {
      var pay_total:CGFloat = 0
      
      if selectCollectionMethod?.id == "-1" && delivery_total > 0 {
        pay_total = total_pay - delivery_total
      }else {
        pay_total = total_pay
      }
      
      payMethods_0.set(key: "pay_method_line_id", value: self.payMethodCard?.id ?? "")
      payMethods_0.set(key: "pay_method_card_id", value: selectPayMethod?.id ?? "")
      payMethods_0.set(key: "paid_amount", value: pay_total)
      payMethods_0.set(key: "real_paid_amount", value: pay_total)
      payMethods.set(key: "0", value: payMethods_0.result,keyType: .string,valueType: .map(1))
      
    }
    data.set(key: "payMethods", value: payMethods.result,keyType: .string,valueType: .map(1))
    
    data.set(key: "bookingTimesData", value: SOAPDictionary().result,keyType: .string,valueType: .map(1))
    
    // 信用卡支付运费
    if methodType == 2 && selectCollectionMethod?.id == "-1" {
      let payFreight_0 = SOAPDictionary()
      payFreight_0.set(key: "pay_method_line_id", value: self.payMethodCard?.id ?? "")
      payFreight_0.set(key: "pay_method_card_id", value: selectPayMethod?.id ?? "")
      payFreight_0.set(key: "paid_amount", value: delivery_total)
      payFreight_0.set(key: "real_paid_amount", value: delivery_total)
      
      data.set(key: "payFreight", value: payFreight_0.result,keyType: .string,valueType: .map(1))
      
    }
    
    //会员卡支付运费
    if (methodType == 0 || methodType == 1) && selectCollectionMethod?.id == "-1" {
      let payFreighVoucher = SOAPDictionary()
      var fee_total = delivery_total
      
      for (i,e) in validNewVouchers.enumerated() {
        let balance = e.balance.cgFloat() ?? 0
        if balance == 0 {
          continue
        }
        
        let Pay_Voucher_item = SOAPDictionary()
        Pay_Voucher_item.set(key: "bought_voucher_id", value: e.id)
        
        if fee_total >= balance {
          Pay_Voucher_item.set(key: "paid_amount", value: balance)
          fee_total -= balance
          e.balance = "0"
        }else {
          Pay_Voucher_item.set(key: "paid_amount", value: fee_total)
          e.balance = (balance - fee_total).string
          fee_total = 0
        }
        
        payFreighVoucher.set(key: i.string, value: Pay_Voucher_item.result,keyType: .string,valueType: .map(1))
        
        if fee_total == 0 {
          break
        }
      }
      
      data.set(key: "payFreightVoucher", value: payFreighVoucher.result,keyType: .string,valueType: .map(1))
    }
    
    mapParams.set(key: "data", value: data.result,type: .map(1))
#if DEBUG
    Toast.showLoading(withStatus: mapParams.path)
#endif
    NetworkManager().request(params: mapParams) { data in
      self.deleteAllCart {
        if self.methodType == 2 {
          self.deductionCreditsNote()
        }else if self.methodType == 1{  // 朋友的卡支付的
//          self.friendCardPayNotification()
        } else {
          self.toNextVc()
        }
      }
      
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
  
  /// 清空购物车
  func deleteAllCart(complete:@escaping ()->()) {
    let params = SOAPParams(action: .Cart, path: .delAllCart)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    let goodsArr = SOAPDictionary()
    orderDetail?.Order_Line_Info?.enumerated().forEach({ i,e in
      goodsArr.set(key: i.string, value: e.product_id ?? "")
    })
    params.set(key: "goodsArr", value: goodsArr.result,type: .map(1))
#if DEBUG
    Toast.showLoading(withStatus: params.path)
#endif
    NetworkManager().request(params: params) { data in
      complete()
    } errorHandler: { e in
      complete()
    }

  }
  
  func deductionCreditsNote() {
    let params = SOAPParams(action: .Notifications, path: .deductionCreditsNote)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "amount", value: total_pay)
    params.set(key: "orderNo", value: orderDetail?.Order_Info?.invoice_no ?? "")
    NetworkManager().request(params: params) { data in
      self.toNextVc()
    } errorHandler: { e in
      self.toNextVc()
    }
    
  }
  
//  用朋友的卡支付时发送推送
  func friendCardPayNotification() {
    let params = SOAPParams(action: .Notifications, path: .friendUseD)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "friendId", value: selectPayMethod?.card_owner_id ?? "")
    params.set(key: "orderId", value: orderId)
    NetworkManager().request(params: params) { data in
      self.toNextVc()
    } errorHandler: { e in
      self.toNextVc()
    }

  }
  
  func toNextVc() {
    Toast.dismiss()
    let vc = ShopOrderSummaryController(orderId: orderDetail?.Order_Info?.id ?? "",status: 2)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
}
