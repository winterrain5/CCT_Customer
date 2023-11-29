//
//  WalletTopupAmountView.swift
//  CCTIOS
//
//  Created by Derrick on 2023/8/22.
//

import UIKit



import UIKit
import Stripe
import PromiseKit
class AmountModel {
  var value:Int
  var isSelect:Bool
  var backgroundColor:UIColor
  var textColor: UIColor
  var borderColor: UIColor
  var level:Int
  
  init(value: Int, backgroundColor: UIColor, level: Int, textColor: UIColor = .white, borderColor:UIColor = R.color.theamRed()!,isSelect: Bool = false) {
    self.value = value
    self.isSelect = isSelect
    self.backgroundColor = backgroundColor
    self.level = level
    self.textColor = textColor
    self.borderColor = borderColor
  }
}
class AmountCell: UICollectionViewCell {
  let amountLabel = UILabel()
  var model:AmountModel! {
    didSet {
      amountLabel.text = "$" + model.value.string
      amountLabel.backgroundColor = model.backgroundColor
      amountLabel.textColor = model.textColor
      contentView.borderWidth = model.isSelect ? 2 : 0
      contentView.borderColor = model.borderColor
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(amountLabel)
    amountLabel.backgroundColor = R.color.theamBlue()
    amountLabel.textColor = .white
    amountLabel.textAlignment = .center
    amountLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    contentView.cornerRadius = 8
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    amountLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
class WalletTopupAmountView: UIView,UITextFieldDelegate {
  @IBOutlet weak var amountLimitDescriptionLabel: UILabel!
  @IBOutlet weak var inputAmountWCons: NSLayoutConstraint!
  @IBOutlet weak var topUpDescriptionLabel: UILabel!
  @IBOutlet weak var inputAmountTf: UITextField!
  @IBOutlet weak var newTierLabel: UILabel!
  @IBOutlet weak var newBalanceLabel: UILabel!
  @IBOutlet weak var newDateLabel: UILabel!
  @IBOutlet weak var doneButton: LoadingButton!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var paymentMethodButton: UIButton!
  @IBOutlet weak var lessthanLabel: UILabel!
  var topUpAmount:String = "100"
  var taxModel:TaxesModel?
  var staffModel:BusinessManModel?
  var voucherModel:NewGiftVoucherModel?
  var orderID:String?
  var orderDetailModel:TopUpOrderDetailModel?
  var clientSecret:String?
  var pointPresentMultiple:String = "1"
  var amounts:[AmountModel] = []
  var memberships = ["Platinum","Gold","Silver"]
  let dateHMS = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
  let dateYMD = Date().string(withFormat: "yyyy-MM-dd")
  
  var currentBalance:CGFloat = 0 
  
  var userInfoModel:UserModel? {
    didSet {
      guard let user = userInfoModel else { return }
      
      
      updateMemberShipTier()
  
      updateBalance(100)
      
      if let expiryDate = user.new_recharge_card_period.date(withFormat: "yyyy-MM-dd") {
        updateNewExpireDate()
        
        if expiryDate.adding(.month, value: -3).unixTimestamp - Date().unixTimestamp <= 0 {
          lessthanLabel.text = "* Less than 3 months"
        } else {
          lessthanLabel.text = ""
        }
        UIView.animate(withDuration: 0.2, delay: 0) {
          self.setNeedsUpdateConstraints()
          self.layoutIfNeeded()
        }
      }
      
    
      
      
      let level = user.new_recharge_card_level.int
      if level == 0 || level == 1 || level == 2 { // basesic
        let m1 = AmountModel(value: 100, backgroundColor: R.color.theamBlue()!, level: 0)
        let m2 = AmountModel(value: 250, backgroundColor: R.color.theamBlue()!, level: 0)
        let m3 = AmountModel(value: 400, backgroundColor: R.color.theamBlue()!, level: 0)
        let m4 = AmountModel(value: 500, backgroundColor: UIColor(hexString: "eeeeee")!, level: 2, textColor: .black, borderColor: R.color.theamBlue()!)
        let m5 = AmountModel(value: 1000, backgroundColor: UIColor(hexString: "#f4b545")!, level: 3, textColor: .black, borderColor: R.color.theamBlue()!)
        let m6 = AmountModel(value: 2000, backgroundColor: UIColor(hexString: "#ffb768")!, level: 4, textColor: .black, borderColor: R.color.theamBlue()!)
        amounts = [m1,m2,m3,m4,m5,m6]
      }
      
      
      if level == 3 { // gold
      
        let m1 = AmountModel(value: 100, backgroundColor: R.color.theamBlue()!, level: 0)
        let m2 = AmountModel(value: 250, backgroundColor: R.color.theamBlue()!, level: 0)
        let m3 = AmountModel(value: 500, backgroundColor: R.color.theamBlue()!, level: 0)
        let m5 = AmountModel(value: 1000, backgroundColor: UIColor(hexString: "#f4b545")!, level: 3, textColor: .black, borderColor: R.color.theamBlue()!)
        let m6 = AmountModel(value: 2000, backgroundColor: UIColor(hexString: "#ffb768")!, level: 4, textColor: .black, borderColor: R.color.theamBlue()!)
        amounts = [m1,m2,m3,m5,m6]
      }
      
      if level == 4 { // platinum
     
        let m1 = AmountModel(value: 100, backgroundColor: R.color.theamBlue()!, level: 0)
        let m2 = AmountModel(value: 250, backgroundColor: R.color.theamBlue()!, level: 0)
        let m3 = AmountModel(value: 500, backgroundColor: R.color.theamBlue()!, level: 0)
        let m5 = AmountModel(value: 1000, backgroundColor: R.color.theamBlue()!, level: 3)
        let m6 = AmountModel(value: 2000, backgroundColor: UIColor(hexString: "#ffb768")!, level: 4, textColor: .black, borderColor: R.color.theamBlue()!)
        amounts = [m1,m2,m3,m5,m6]
      }
      
      collectionView.reloadData()
    }
  }
  
  var payPd = ""

  override func awakeFromNib() {
    super.awakeFromNib()
    
    inputAmountTf.delegate = self
    inputAmountTf.rx.controlEvent(.editingChanged).subscribe(onNext:{ [weak self] in
      guard let `self` = self else { return }
      let w = (self.inputAmountTf.text?.widthWithConstrainedWidth(height: 0, font: UIFont.systemFont(ofSize: 44, weight: .semibold)) ?? 0)
      
      self.inputAmountWCons.constant = w < 90 ? 90 : w + 8
      
      let amout = self.inputAmountTf.text?.cgFloat() ?? 0
      if amout < 100 {
        self.amountLimitDescriptionLabel.text = "* Minimum Top up amount of $100 is required."
      } else {
        self.amountLimitDescriptionLabel.text = ""
      }
      
      UIView.animate(withDuration: 0, delay: 0) {
        self.setNeedsUpdateConstraints()
        self.layoutIfNeeded()
      }
     
    }).disposed(by: rx.disposeBag)
    
    collectionView.backgroundColor = .white
    collectionView.register(cellWithClass: AmountCell.self)
  
 
    if  Defaults.shared.get(for: .payMethodLine)  != nil {
      doneButton.backgroundColor = R.color.theamBlue()
      doneButton.isEnabled = true
    }
    
    getAllTax()
    getBusiness()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  

  
  @IBAction func topUpAction(_ sender: LoadingButton) {
    if Defaults.shared.get(for: .payMethodLine) == nil {
      Toast.showError(withStatus: "Please choose a recharge card")
      return
    }
    let pin = Defaults.shared.get(for: .userModel)?.pay_password ?? ""
    CardDigitPinView.showView(pin: pin) { newPin in
      self.payPd = newPin
      Toast.showLoading(withStatus: "Top Up...")
      firstly {
        self.saveNewGiftVoucher()
      }.then {
        self.checkoutTOrder()
      }.then {
        self.getCheckoutDetails()
      }.then {
        self.getClientVipLevel()
      }.then {
        self.createInstance()
      }.then {
        self.startPay()
      }.then {
        self.payOrder()
      }.done {
        self.topupNotification()
      }.catch { e in
        Toast.showError(withStatus: e.asAPIError.errorInfo().message)
      }
    }
  }
  
  /// 获取所有税率
  func getAllTax() {
    let params = SOAPParams(action: .Tax, path: .getTAllTaxes,isNeedToast: false)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeByCodable([TaxesModel].self, from: data) {
        self.taxModel = models.first
      }else {
        let taxModel = TaxesModel()
        taxModel.id = "0"
        taxModel.rate = "7"
        taxModel.tax_code = "GST"
        self.taxModel = taxModel
      }
    } errorHandler: { e in
      
    }
  }
  /// 获取默认的负责员工
  func getBusiness() {
    let params = SOAPParams(action: .Employee, path: .getBusiness,isNeedToast: false)
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeByCodable(BusinessManModel.self, from: data) {
        self.staffModel = model
      }
    } errorHandler: { e in
      
    }
  }
  
  func saveNewGiftVoucher() -> Promise<Void> {
    Promise.init { resolver in
      let mapParams = SOAPParams(action: .Voucher, path: .saveNewGiftVoucher)
      let data = SOAPDictionary()
      data.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      data.set(key: "name", value: "New Recharge Card")
      data.set(key: "voucher_type", value: "2")
      data.set(key: "voucher_value", value: topUpAmount)
      data.set(key: "voucher_pay_code", value: "")
      data.set(key: "cct_mp_type", value: "1")
      data.set(key: "recharge_level", value: "")
      data.set(key: "recharge_type", value: "2") // 充值
      data.set(key: "service_type", value: "2")
      data.set(key: "expiry_period_date", value: "12")
      data.set(key: "enable_sales", value: "0")
      data.set(key: "default_count_in_pos", value: "1")
      data.set(key: "create_time", value: Date().string(withFormat: "yyyy-MM-dd HH:mm:ss"))
      data.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
      data.set(key: "is_delet", value: "0")
      
      mapParams.set(key: "data", value: data.result,type: .map(1))
#if DEBUG
      Toast.showLoading(withStatus: mapParams.path)
#endif
      
      NetworkManager().request(params: mapParams) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(NewGiftVoucherModel.self, from: data) {
          self.voucherModel = model
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode NewGiftVoucherModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
      
    }
  }
  
  func checkoutTOrder() -> Promise<Void> {
    Promise.init { resolver in
      
      if staffModel == nil {
        resolver.reject(APIError.requestError(code: -1, message: "The default responsible employee has not been obtained"))
        return
      }
      
      if taxModel == nil {
        resolver.reject(APIError.requestError(code: -1, message: "The current tax rate has not been obtained"))
        return
      }
      
      let mapParams = SOAPParams(action: .Sale, path: .checkoutTOrder)
      
      let data = SOAPDictionary()
      
      let clientInfo = SOAPDictionary()
      clientInfo.set(key: "id", value: Defaults.shared.get(for: .clientId) ?? "")
      clientInfo.set(key: "pay_password", value: self.payPd)
      clientInfo.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
      data.set(key: "Client_Info", value: clientInfo.result, keyType: .string, valueType: .map(1))
      
      let orderInfo = SOAPDictionary()
      orderInfo.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      orderInfo.set(key: "location_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      orderInfo.set(key: "customer_id", value: Defaults.shared.get(for: .clientId) ?? "")
      orderInfo.set(key: "subtotal", value: topUpAmount)
      orderInfo.set(key: "total", value: topUpAmount)
      orderInfo.set(key: "category", value: 2)
      orderInfo.set(key: "type", value: 1)
      orderInfo.set(key: "status", value: 0)
      orderInfo.set(key: "invoice_date", value: dateHMS)
      orderInfo.set(key: "due_date", value: dateYMD)
      orderInfo.set(key: "create_time", value: dateHMS)
      orderInfo.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
      orderInfo.set(key: "is_delete", value: "0")
      orderInfo.set(key: "is_from_app", value: "1")
      data.set(key: "Order_Info", value: orderInfo.result, keyType: .string, valueType: .map(1))
      
      let orderLines = SOAPDictionary()
      let orderLine0 = SOAPDictionary()
      let orderLineItem = SOAPDictionary()
      
      orderLineItem.set(key: "product_category", value: "9")
      orderLineItem.set(key: "product_id", value: self.voucherModel?.id ?? 0)
      orderLineItem.set(key: "name", value: "Top Up:\(topUpAmount)")
      orderLineItem.set(key: "location_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      orderLineItem.set(key: "price", value: topUpAmount)
      orderLineItem.set(key: "qty", value: 1)
      orderLineItem.set(key: "present_qty", value: 0)
      orderLineItem.set(key: "product_unit_id", value: "")
      orderLineItem.set(key: "discount_id", value: 0)
      orderLineItem.set(key: "discount_id2", value: 0)
      orderLineItem.set(key: "tax_id", value: self.taxModel?.id ?? "")
      
      let voucher = topUpAmount.float() ?? 0
      let rate = self.taxModel?.rate?.float() ?? 0
      let tax = (voucher - (voucher / (1 + rate / 100)))
      orderLineItem.set(key: "tax", value: tax)
      
      orderLineItem.set(key: "tax_is_include", value: 1)
      orderLineItem.set(key: "total", value: topUpAmount)
      orderLineItem.set(key: "cost", value: topUpAmount)
      orderLineItem.set(key: "retail_price", value: topUpAmount)
      orderLineItem.set(key: "staff_id", value: self.staffModel?.id ?? "")
      orderLineItem.set(key: "staff_id2", value: 0)
      orderLineItem.set(key: "appoint_sale_id", value: "")
      orderLineItem.set(key: "responsible_doctor", value: 0)
      orderLineItem.set(key: "referrer", value: 0)
      orderLineItem.set(key: "equal_staffs", value: "")
      orderLineItem.set(key: "collection_method", value: 1)
      orderLineItem.set(key: "has_delivered", value: 1)
      orderLineItem.set(key: "create_time", value: dateHMS)
      orderLineItem.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
      orderLineItem.set(key: "is_delete", value: "0")
      orderLineItem.set(key: "delivery_time", value: dateHMS)
      orderLineItem.set(key: "delivery_location_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      orderLine0.set(key: "data", value: orderLineItem.result, keyType: .string, valueType: .map(1))
      
      let vouchers = SOAPDictionary()
      let vouchers_0 = SOAPDictionary()
      
      vouchers_0.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
      let uuid = UUID(uuidString: Date().second.string)?.uuidString ?? ""
      vouchers_0.set(key: "voucher_code", value: "1" + uuid.md5)
      vouchers_0.set(key: "voucher_manual_code", value: "")
      vouchers_0.set(key: "create_date", value: dateHMS)
      vouchers_0.set(key: "voucher_type", value: 5)
      vouchers_0.set(key: "voucher_id", value: voucherModel?.id ?? "")
      vouchers_0.set(key: "present_value", value: 0)
      vouchers_0.set(key: "present_balance", value: 0)
      vouchers_0.set(key: "type", value: "1")
      
      vouchers.set(key: "0", value: vouchers_0.result, keyType: .string, valueType: .map(1))
      
      orderLine0.set(key: "vouchers", value: vouchers.result, keyType: .string, valueType: .map(1))
      
      orderLines.set(key: "0", value: orderLine0.result, keyType: .string, valueType: .map(1))
      
      data.set(key: "Order_Lines", value: orderLines.result, keyType: .string, valueType: .map(1))
      
      mapParams.set(key: "data", value: data.result, type: .map(1))
      
      let logData = SOAPDictionary()
      logData.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
      mapParams.set(key: "logData", value: logData.result, type: .map(2))
      
#if DEBUG
      Toast.showLoading(withStatus: mapParams.path)
#endif
      
      NetworkManager().request(params: mapParams) { data in
        if let id = JSON.init(from: data)?.rawString() {
          self.orderID = id
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Get OrderID Failed"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
      
    }
  }
  
  func getCheckoutDetails() -> Promise<Void> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Sale, path: .getCheckoutDetails)
      params.set(key: "orderId", value: self.orderID ?? "")
#if DEBUG
      Toast.showLoading(withStatus: params.path)
#endif
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(TopUpOrderDetailModel.self, from: data) {
          self.orderDetailModel = model
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode TopUpOrderDetailModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
    }
  }
  
  func getClientVipLevel() -> Promise<Void> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Sale, path: .getClientVipLevel)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
#if DEBUG
      Toast.showLoading(withStatus: params.path)
#endif
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(ClientVipLevelModel.self, from: data) {
          self.pointPresentMultiple = model.point_present_multiple ?? "1"
          resolver.fulfill_()
        }else {
          resolver.fulfill_()
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
      
    }
  }
  
  func createInstance() -> Promise<Void> {
    Promise.init { resolver in
      let params = SOAPParams(action: .StripePayment, path: .createInstance)
      
      let data = SOAPDictionary()
      data.set(key: "totalAmount", value: (topUpAmount.formatMoney().float() ?? 0) * 100)
      data.set(key: "email", value: Defaults.shared.get(for: .userModel)?.email ?? "")
      data.set(key: "invoice_no", value: self.orderDetailModel?.Order_Info?.invoice_no ?? "")
      data.set(key: "orderId", value: self.orderID ?? "")
      
      params.set(key: "data", value: data.result,type: .map(1))
#if DEBUG
      Toast.showLoading(withStatus: params.path)
#endif
      NetworkManager().request(params: params) { data in
        if let secret = JSON.init(from: data)?["clientSecret"].stringValue,!secret.isEmpty {
          self.clientSecret = secret
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Credit card payment failed"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: "Credit card payment failed"))
      }
      
    }
  }
  
  func startPay() -> Promise<Void> {
    Promise.init { resolver in
      let model = Defaults.shared.get(for: .payMethodLine)
      let card = STPPaymentMethodCardParams()
      card.cvc = model?.authorisation_code ?? ""
      if let date = model?.expiry_date?.date(withFormat: "yyyy-MM-dd") {
        card.expYear = NSNumber.init(value: date.year.uInt)
        card.expMonth =  NSNumber.init(value: date.month.uInt)
      }
      card.number = model?.card_number
      let params = STPPaymentMethodParams(card: card, billingDetails: nil, metadata: nil)
      
      let intent = STPPaymentIntentParams(clientSecret: self.clientSecret ?? "")
      intent.paymentMethodParams = params
      
#if DEBUG
      Toast.showLoading(withStatus: "Stripe SDK ConfirmPayment")
#endif
      STPAPIClient().confirmPaymentIntent(with: intent) { result, e in
        if e != nil {
          print(e)
          resolver.reject(APIError.requestError(code: -1, message: "Credit card payment failed"))
          return
        }else {
          resolver.fulfill_()
        }
      }
    }
  }
  
  func payOrder() -> Promise<Void> {
    Promise.init { resolver in
      let mapParams = SOAPParams(action: .Sale, path: .payTOrder)
      let data = SOAPDictionary()
      
      let orderInfo = SOAPDictionary()
      orderInfo.set(key: "id", value: self.orderDetailModel?.Order_Info?.id ?? "")
      orderInfo.set(key: "date", value: dateYMD)
      orderInfo.set(key: "total_recharge_discount", value: 0)
      orderInfo.set(key: "paid_amount", value: topUpAmount)
      orderInfo.set(key: "origin_paid_amount", value: topUpAmount)
      orderInfo.set(key: "gift_voucher_amount", value: "0")
      orderInfo.set(key: "new_gift_voucher_amount", value: "0")
      orderInfo.set(key: "voucher_amount", value: "0")
      orderInfo.set(key: "pay_by_balance", value: "0")
      orderInfo.set(key: "pay_by_gift", value: "0")
      orderInfo.set(key: "pay_by_service", value: "0")
      orderInfo.set(key: "change", value: "0")
      orderInfo.set(key: "saleman_id", value: staffModel?.id ?? "")
      orderInfo.set(key: "balance", value: "0")
      orderInfo.set(key: "remark", value: "")
      
      var presentPoints = topUpAmount.float() ?? 0
      if let birthDay = Defaults.shared.get(for: .userModel)?.birthday.date(withFormat: "yyyy-MM-dd") {
        if birthDay.isInCurrentMonth && birthDay.isInToday {
          presentPoints *= 2
        }
      }
      presentPoints *= (pointPresentMultiple.float() ?? 0)
      
      orderInfo.set(key: "present_points", value: presentPoints)
      orderInfo.set(key: "invoice_date", value: dateYMD)
      orderInfo.set(key: "due_date", value: dateYMD)
      orderInfo.set(key: "close_time", value: dateHMS)
      orderInfo.set(key: "status", value: 1)
      orderInfo.set(key: "is_from_app", value: 1)
      
      data.set(key: "Order_Info", value: orderInfo.result,keyType: .string,valueType: .map(1))
      
      let orderLines = SOAPDictionary()
      let orderLines0 = SOAPDictionary()
      let orderLinesItem = SOAPDictionary()
      
      orderLinesItem.set(key: "id", value: orderDetailModel?.Order_Line_Info?.first?.id ?? "")
      orderLinesItem.set(key: "salesmen_id", value: staffModel?.id ?? "")
      orderLinesItem.set(key: "has_paid", value: 1)
      orderLinesItem.set(key: "pay_by_balance", value: 0)
      orderLinesItem.set(key: "pay_by_voucher", value: 0)
      orderLinesItem.set(key: "pay_by_gift", value: 0)
      orderLinesItem.set(key: "pay_by_service", value: 0)
      orderLinesItem.set(key: "new_recharge_discount", value: 0)
      
      orderLines0.set(key: "data", value: orderLinesItem.result,keyType: .string,valueType: .map(1))
      orderLines.set(key: "0", value: orderLines0.result,keyType: .string,valueType: .map(1))
      
      data.set(key: "Order_Lines", value: orderLines.result,keyType: .string,valueType: .map(1))
      
      let payMethods = SOAPDictionary()
      let payMethods0 = SOAPDictionary()
      
      payMethods0.set(key: "pay_method_line_id", value: Defaults.shared.get(for: .payMethodId) ?? "")
      payMethods0.set(key: "pay_method_card_id", value: Defaults.shared.get(for: .payMethodLine)?.id ?? "")
      payMethods0.set(key: "paid_amount", value: topUpAmount)
      payMethods0.set(key: "real_paid_amount", value: topUpAmount)
      
      payMethods.set(key: "0", value: payMethods0.result,keyType: .string,valueType: .map(1))
      
      data.set(key: "payMethods", value: payMethods.result,keyType: .string,valueType: .map(1))
      
      let bookingTimesData = SOAPDictionary()
      data.set(key: "bookingTimesData", value: bookingTimesData.result, keyType: .string,valueType: .map(1))
      
      mapParams.set(key: "data", value: data.result, type: .map(1))
      
      let logData = SOAPDictionary()
      logData.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
      mapParams.set(key: "logData", value: logData.result, type: .map(2))
      
#if DEBUG
      Toast.showLoading(withStatus: mapParams.path)
#endif
      NetworkManager().request(params: mapParams) { data in
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: "Top Up Failed"))
      }
      
      
    }
  }
  
  /// 以下是通知
  func topupNotification()  {
    let params = SOAPParams(action: .Notifications, path: .topupNote,isNeedToast: false)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "amount", value: topUpAmount)
    NetworkManager().request(params: params) { data in
      self.deductionCreditsNotification()
    } errorHandler: { e in
      self.deductionCreditsNotification()
    }
  }
  
  func deductionCreditsNotification()  {
    let params = SOAPParams(action: .Notifications, path: .deductionCreditsNote,isNeedToast: false)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "amount", value: topUpAmount)
    params.set(key: "orderNo", value: orderDetailModel?.Order_Info?.invoice_no ?? "")
    NetworkManager().request(params: params) { data in
     
    } errorHandler: { e in
      
    }
    self.getLeveUp()
  }
  
  func getLeveUp()  {
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo,isNeedToast: false)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let newModel = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data),let oldModel = Defaults.shared.get(for: .userModel),newModel.new_recharge_card_level != oldModel.new_recharge_card_level {
        self.getNewCardDiscountsByLevel(newModel)
      }else {
        self.popBack()
      }
    } errorHandler: { e in
      self.popBack()
    }
  }
  
  func getNewCardDiscountsByLevel(_ model:UserModel) {
    let params = SOAPParams(action: .VipDefinition, path: .getNewCardDiscountsByLevel,isNeedToast: false)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "cardLevel", value: model.new_recharge_card_level)
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(CardDiscountModel.self, from: data) {
        self.upgradedTierLevel(user: model, discount: models.first?.discount_percent ?? "")
      }
    } errorHandler: { e in
      self.popBack()
    }
    
  }
  
  func upgradedTierLevel(user:UserModel,discount:String) {
    let params = SOAPParams(action: .Notifications, path: .upgradedTierLevel)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "level", value: user.new_recharge_card_level)
    params.set(key: "discount", value: discount)
    NetworkManager().request(params: params) { data in
      self.popBack()
    } errorHandler: { e in
      self.popBack()
    }
    
  }
  
  func popBack() {
    Toast.showSuccess(withStatus: "Successful Top Up")
    let item = DispatchWorkItem {
      UIViewController.getTopVc()?.navigationController?.popViewController()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: item)
    
  }
  
  @IBAction func selectPaymethodAction(_ sender: Any) {
    let vc = WalletPaymentMethodController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
  func reloadPaymentMethod() {
    if let model = Defaults.shared.get(for: .payMethodLine) {
      paymentMethodButton.titleForNormal = " \(model.name_on_card ?? "")"
      paymentMethodButton.imageForNormal = R.image.transaction_payment_other()
    }else {
      paymentMethodButton.titleForNormal = "Add Payment Method"
      paymentMethodButton.imageForNormal = nil
    }
    updateDoneButtonStatus()
  }
  
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let amount = textField.text?.cgFloat() ?? 0
    topUpAmount = amount.string
    let level = userInfoModel?.new_recharge_card_level.int ?? 0
    if amount < 100 {
      updateDoneButtonStatus()
      updateBalance(0)
      return
    }
    let currency = amount.asLocaleCurrency ?? ""
    if level == 4 {
      if amount < 500 {
        topUpDescriptionLabel.text = ""
        updateMemberShipTier()
        updateNewExpireDate(false)
        lessthanLabel.text = ""
      }else if amount >= 2000 {
        topUpDescriptionLabel.text = "Topping up \(currency) extends you a Platinum Membership for 12 months."
        updateNewExpireDate()
        lessthanLabel.text = ""
        
      } else {
        topUpDescriptionLabel.text = ""
        updateLessThanText()
      }
    }
    
    if level == 3 {
      if amount < 500 {
        topUpDescriptionLabel.text = ""
        updateMemberShipTier()
        updateNewExpireDate(false)
        lessthanLabel.text = ""
      }else if amount >= 1000 && amount < 2000 {
        topUpDescriptionLabel.text = "Topping up \(currency) extends you a Gold Membership for 12 months."
        updateMemberShipTier()
        updateNewExpireDate()
        lessthanLabel.text = ""
        
      } else if amount >= 2000 {
        topUpDescriptionLabel.text = "Topping up \(currency) entitle you a Platinum Membership for 12 months."
        updateNewExpireDate()
        updateMemberShipTier("Platinum")
        lessthanLabel.text = ""
      }
      else {
        topUpDescriptionLabel.text = ""
        updateLessThanText()
      }
    }
    if level == 2 {
      if amount < 500 {
        topUpDescriptionLabel.text = ""
        updateMemberShipTier()
        updateNewExpireDate(false)
        lessthanLabel.text = ""
      }else if amount >= 500 && amount < 1000 {
        topUpDescriptionLabel.text = "Topping up \(currency) extends you a Silver Membership for 12 months."
        updateMemberShipTier()
        updateNewExpireDate()
        lessthanLabel.text = ""
      } else if amount >= 1000 && amount < 2000 {
        topUpDescriptionLabel.text = "Topping up \(currency) entitle you a Gold Membership for 12 months."
        updateMemberShipTier("Gold")
        updateNewExpireDate()
        lessthanLabel.text = ""
        
      } else if amount >= 2000 {
        topUpDescriptionLabel.text = "Topping up \(currency) entitle you a Platinum Membership for 12 months."
        updateMemberShipTier("Platinum")
        updateNewExpireDate()
        lessthanLabel.text = ""
      }
      else {
        topUpDescriptionLabel.text = ""
        updateLessThanText()
      }
    }
    if level == 1 || level == 0  { // basic
      if amount < 500 {
        topUpDescriptionLabel.text = ""
        updateMemberShipTier()
        updateNewExpireDate(false)
        lessthanLabel.text = ""
      } else if amount >= 500 && amount < 1000 {
        topUpDescriptionLabel.text = "Topping up \(currency) entitle you a Silver Membership for 12 months."
        updateMemberShipTier()
        updateNewExpireDate()
        lessthanLabel.text = ""
      } else if amount >= 1000 && amount < 2000 {
        topUpDescriptionLabel.text = "Topping up \(currency) entitle you a Gold Membership for 12 months."
        updateMemberShipTier("Gold")
        updateNewExpireDate()
        lessthanLabel.text = ""
        
      } else if amount >= 2000 {
        topUpDescriptionLabel.text = "Topping up \(currency) entitle you a Platinum Membership for 12 months."
        updateMemberShipTier("Platinum")
        updateNewExpireDate()
        lessthanLabel.text = ""
      }
      else {
        topUpDescriptionLabel.text = ""
        updateLessThanText()
      }
    }
    UIView.animate(withDuration: 0.25, delay: 0) {
      self.setNeedsUpdateConstraints()
      self.layoutIfNeeded()
    }
   
    updateBalance(amount)
    updateDoneButtonStatus()
  }
  func updateNewExpireDate(_ isNewExpire:Bool = true) {
    if !isNewExpire {
      if let expiryDate = userInfoModel?.new_recharge_card_period.date(withFormat: "yyyy-MM-dd") {
        let expirDateStr = expiryDate.string(withFormat: "dd MMM yyyy")
        let attr3 = NSMutableAttributedString(string: "Expiry Date: \(expirDateStr)")
        attr3.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: NSRange(location: 13, length: expirDateStr.count))
        newDateLabel.attributedText = attr3
      }
      return
    }
      let expiryDate = Date().adding(.year, value: 1).string(withFormat: "dd MMM yyyy")
      let attr3 = NSMutableAttributedString(string: "New Expiry Date: \(expiryDate)")
      attr3.addAttribute(.font, value: UIFont.systemFont(ofSize: 22, weight: .semibold), range: NSRange(location: 17, length: expiryDate.count))
      newDateLabel.attributedText = attr3
    }
    func updateLessThanText() {
      if let expiryDate = userInfoModel?.new_recharge_card_period.date(withFormat: "yyyy-MM-dd") {
        
        if expiryDate.adding(.month, value: -3).unixTimestamp - Date().unixTimestamp <= 0 {
          lessthanLabel.text = "* Less than 3 months"
        } else {
          lessthanLabel.text = ""
        }
        UIView.animate(withDuration: 0.2, delay: 0) {
          self.setNeedsUpdateConstraints()
          self.layoutIfNeeded()
        }
      }
    }
    func updateMemberShipTier(_ membership:String? = nil) {
      if let membership {
        let attr = NSMutableAttributedString(string: "New Membership Tier: \(membership)")
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: NSRange(location: 21, length: membership.count))
        newTierLabel.attributedText = attr
      } else {
        let originMemberShip = userInfoModel?.new_recharge_card_level_text.split(separator: " ").first ?? "Basic"
        let attr = NSMutableAttributedString(string: "Membership Tier: \(originMemberShip)")
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: NSRange(location: 17, length: originMemberShip.count))
        newTierLabel.attributedText = attr
      }
     
    }
  func updateBalance(_ value:CGFloat) {
    let newBalance = (currentBalance + value).asLocaleCurrency ?? ""
    let attr2 = NSMutableAttributedString(string: "Credit balance after top up: \(newBalance)")
    attr2.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: NSRange(location: 29, length: newBalance.count))
    newBalanceLabel.attributedText = attr2
  }
  
  func updateDoneButtonStatus() {
    if (Defaults.shared.get(for: .payMethodLine) != nil) && topUpAmount.isEmpty == false && (topUpAmount.cgFloat() ?? 0) >= 100 {
      self.doneButton.backgroundColor = R.color.theamBlue()
      self.doneButton.isEnabled = true
    } else {
      self.doneButton.backgroundColor = R.color.line()
      self.doneButton.isEnabled = false
    }
  }

}

extension WalletTopupAmountView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return amounts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: AmountCell.self, for: indexPath)
    cell.model = amounts[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let w = (kScreenWidth - 48 - 32) / 3
    let h = 44
    return CGSize(width: w, height: h.cgFloat)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    16
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    16
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    amounts.forEach({ $0.isSelect = false })
    let model = amounts[indexPath.item]
    model.isSelect = true
    let level = userInfoModel?.new_recharge_card_level.int ?? 0
    
    
    if level == 4 {
      if model.level == 0 {
        topUpDescriptionLabel.text = ""
        updateMemberShipTier()
        updateNewExpireDate(false)
        lessthanLabel.text = ""
      }
      if model.level == 4 {
        topUpDescriptionLabel.text = "Topping up $2,000 extends you a Platinum Membership for 12 months."
        updateNewExpireDate()
        lessthanLabel.text = ""
        
      } else {
        topUpDescriptionLabel.text = ""
        updateLessThanText()
        updateNewExpireDate(false)
      }
    }
    
    if level == 3 {
      if model.level == 0 {
        topUpDescriptionLabel.text = ""
        updateMemberShipTier()
        updateNewExpireDate(false)
        lessthanLabel.text = ""
      }
      if model.level == 3 {
        topUpDescriptionLabel.text = "Topping up $1,000 extends you a Gold Membership for 12 months."
        updateMemberShipTier()
        updateNewExpireDate()
        lessthanLabel.text = ""
        
      } else if model.level == 4 {
        topUpDescriptionLabel.text = "Topping up $2,000 entitle you a Platinum Membership for 12 months."
        updateNewExpireDate()
        updateMemberShipTier("Platinum")
        lessthanLabel.text = ""
      }
      else {
        topUpDescriptionLabel.text = ""
        updateLessThanText()
        updateNewExpireDate(false)
      }
    }
    if level == 2 {
      if model.level == 0 {
        topUpDescriptionLabel.text = ""
        updateMemberShipTier()
        updateNewExpireDate(false)
        lessthanLabel.text = ""
      }
      if model.level == 2 {
        topUpDescriptionLabel.text = "Topping up $500 extends you a Silver Membership for 12 months."
        updateMemberShipTier()
        updateNewExpireDate()
        lessthanLabel.text = ""
      } else if model.level == 3 {
        topUpDescriptionLabel.text = "Topping up $1,000 entitle you a Gold Membership for 12 months."
        updateMemberShipTier("Gold")
        updateNewExpireDate()
        lessthanLabel.text = ""
        
      } else if model.level == 4 {
        topUpDescriptionLabel.text = "Topping up $2,000 entitle you a Platinum Membership for 12 months."
        updateMemberShipTier("Platinum")
        updateNewExpireDate()
        lessthanLabel.text = ""
      }
      else {
        topUpDescriptionLabel.text = ""
        updateLessThanText()
        updateNewExpireDate(false)
      }
    }
    if level == 1 || level == 0  { // basic
      if model.level == 0 {
        topUpDescriptionLabel.text = ""
        updateMemberShipTier()
        updateNewExpireDate(false)
        lessthanLabel.text = ""
      }
      if model.level == 2 {
        topUpDescriptionLabel.text = "Topping up $500 entitle you a Silver Membership for 12 months."
        updateMemberShipTier("Silver")
        updateNewExpireDate()
        lessthanLabel.text = ""
      } else if model.level == 3 {
        topUpDescriptionLabel.text = "Topping up $1,000 entitle you a Gold Membership for 12 months."
        updateMemberShipTier("Gold")
        updateNewExpireDate()
        lessthanLabel.text = ""
        
      } else if model.level == 4 {
        topUpDescriptionLabel.text = "Topping up $2,000 entitle you a Platinum Membership for 12 months."
        updateMemberShipTier("Platinum")
        updateNewExpireDate()
        lessthanLabel.text = ""
      }
      else {
        topUpDescriptionLabel.text = ""
        updateLessThanText()
        updateNewExpireDate(false)
      }
    }
    amountLimitDescriptionLabel.text = ""
    updateBalance(model.value.cgFloat)
    inputAmountTf.text = model.value.string
    topUpAmount = model.value.string
    
    let w = model.value.string.widthWithConstrainedWidth(height: 0, font: UIFont.systemFont(ofSize: 44, weight: .semibold))
    
    self.inputAmountWCons.constant = w < 90 ? 90 : w + 8
    
    UIView.animate(withDuration: 0.25, delay: 0) {
      self.setNeedsUpdateConstraints()
      self.layoutIfNeeded()
    }
    collectionView.reloadData()
    
    updateDoneButtonStatus()
    
  }

  
}
