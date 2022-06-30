//
//  WalletTopUpContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/10.
//

import UIKit
import Stripe
import PromiseKit
class WalletTopUpContainer: UIView,UITextFieldDelegate {
  @IBOutlet weak var amountTf: UITextField!
  var limitAmoutSelectButton:UIButton?
  @IBOutlet weak var limitAmountLabel: UILabel!
  @IBOutlet weak var limit1Button: UIButton!
  @IBOutlet weak var limit2Button: UIButton!
  @IBOutlet weak var limit5Button: UIButton!
  @IBOutlet weak var limit10Button: UIButton!
  @IBOutlet weak var limit20Button: UIButton!
  @IBOutlet weak var limit25Button: UIButton!
  @IBOutlet weak var doneButton: LoadingButton!
  @IBOutlet weak var paymentMethodButton: UIButton!
  var taxModel:TaxesModel?
  var staffModel:BusinessManModel?
  var voucherModel:NetGiftVoucherModel?
  var orderID:String?
  var orderDetailModel:TopUpOrderDetailModel?
  var clientSecret:String?
  var pointPresentMultiple:String = "1"
  var amount:[String] = ["100.00","200.00","500.00","1000.00","2000.00","2500.00"]
  let dateHMS = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
  let dateYMD = Date().string(withFormat: "yyyy-MM-dd")
  var payPd = ""
  var topUpAmount:String {
    get {
      (amountTf.text?.trimmed ?? "").removingPrefix("$")
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    amountTf.delegate = self
    amountTf.keyboardType = .numberPad
    
    if  Defaults.shared.get(for: .payMethodLine)  != nil {
      doneButton.backgroundColor = R.color.theamRed()
      doneButton.isEnabled = true
    }
    
    
    getAllTax()
    getBusiness()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  @IBAction func limitAmoutButtonAction(_ sender: UIButton) {
    
    
    if let sel = limitAmoutSelectButton {
      sel.isSelected = false
    }
    
    sender.isSelected.toggle()
    
    if sender.isSelected {
      sender.backgroundColor = R.color.theamBlue()
      sender.titleColorForNormal = .white
      
      if let sel = limitAmoutSelectButton,sel != sender {
        sel.backgroundColor = R.color.grayf2()
        sel.titleColorForNormal = .black
      }
      
      doneButton.backgroundColor = R.color.theamRed()
      doneButton.isEnabled = true
      
    }else {
      sender.backgroundColor = R.color.grayf2()
      sender.titleColorForNormal = .black
      
      doneButton.backgroundColor = R.color.line()
      doneButton.isEnabled = false
    }
    
    amountTf.text = "$" + amount[sender.tag]
    
    limitAmoutSelectButton = sender
  }
  
  @IBAction func topUpAction(_ sender: LoadingButton) {
    if Defaults.shared.get(for: .payMethodLine) == nil {
      Toast.showError(withStatus: "Please choose a recharge card")
      return
    }
    let pin = Defaults.shared.get(for: .userModel)?.pay_password ?? ""
    CardDigitPinView.showView(pin: pin) { newPin in
      self.payPd = newPin
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
      data.set(key: "recharge_type", value: "1")
      data.set(key: "service_type", value: "3")
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
        if let model = DecodeManager.decodeByCodable(NetGiftVoucherModel.self, from: data) {
          self.voucherModel = model
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode NetGiftVoucherModel Failed"))
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
      vouchers_0.set(key: "voucher_manual_code", value: uuid)
      vouchers_0.set(key: "create_date", value: dateHMS)
      vouchers_0.set(key: "voucher_type", value: 5)
      vouchers_0.set(key: "voucher_id", value: voucherModel?.id ?? "")
      vouchers_0.set(key: "present_value", value: 0)
      vouchers_0.set(key: "present_balance", value: 0)
      
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
        if let model = DecodeManager.decodeByCodable(TopUpOrderDetailModel.self, from: data) {
          self.orderDetailModel = model
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode MyOrderDetailModel Failed"))
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
        if let model = DecodeManager.decodeByCodable(ClientVipLevelModel.self, from: data) {
          self.pointPresentMultiple = model.point_present_multiple ?? "1"
          resolver.fulfill_()
        }else {
          resolver.fulfill_()
        }
      } errorHandler: { e in
        resolver.fulfill_()
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
      
      payMethods.set(key: "pay_method_line_id", value: Defaults.shared.get(for: .payMethodId) ?? "")
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
      if let models = DecodeManager.decodeByCodable([CardDiscountModel].self, from: data) {
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
    Toast.showSuccess(withStatus: "Top Up Success")
    UIViewController.getTopVc()?.navigationController?.popViewController()
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
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    doneButton.backgroundColor = R.color.theamRed()
    doneButton.isEnabled = true
  }
}
