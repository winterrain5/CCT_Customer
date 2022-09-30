//
//  HomeServiceViewController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/9/29.
//

import UIKit

class HomeServiceViewController: BaseViewController {
  
  private var orderId: String = ""
  private var sessionId: String = ""
  private var scrollView = UIScrollView()
  private var textLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:24)
    label.text = "Please confirm your order"
    label.textAlignment = .center
    label.numberOfLines = 2
  }
  private var headerView = MyOrderDetailHeaderView.loadViewFromNib()
  private var footerView = HomeServiceFooterView()
  private var returnButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.titleForNormal = "Confirm"
  }
  private var orderDetail: MyOrderDetailModel?
  let dateHMS = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
  let dateYMD = Date().string(withFormat: "yyyy-MM-dd")
  convenience init(orderId: String, sessionId: String) {
    self.init()
    self.orderId = orderId
    self.sessionId = sessionId
  }
 

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Order Summary"
    
    self.view.addSubview(scrollView)
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    scrollView.contentSize = CGSize(width: kScreenWidth, height: 0)
    
    scrollView.addSubview(textLabel)
    textLabel.frame = CGRect(x: 16, y: 0, width: kScreenWidth - 32, height: 114)
    self.scrollView.contentSize.height += 114
    
    scrollView.addSubview(headerView)
    headerView.status = 3
    headerView.frame = CGRect(x: 0, y: textLabel.frame.maxY, width: kScreenWidth, height: 0)
    headerView.updateHeightHandler = { [weak self] height in
      self?.headerView.height = height
      self?.scrollView.contentSize.height += height
    }
    
    scrollView.addSubview(footerView)
    footerView.frame = CGRect(x: 20, y: headerView.frame.maxY, width: kScreenWidth - 40, height: 0)
    footerView.backgroundColor = R.color.theamYellow()
    footerView.cornerRadius = 16
    footerView.updateHeightHandler = { [weak self] height in
      self?.footerView.height = height
      self?.footerView.frame.origin.y = self?.headerView.frame.maxY ?? 0
      self?.scrollView.contentSize.height += (height + 40)
    }
    
    self.view.addSubview(returnButton)
    returnButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    returnButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(32)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(40 + kBottomsafeAreaMargin)
    }
    
    scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84 + kBottomsafeAreaMargin, right: 0)

    
    addLeftBarButtonItem()
    leftButtonDidClick = { [weak self] in
      self?.navigationController?.popToRootViewController(animated: true)
    }
    
    interactivePopGestureRecognizerEnable = false
    
    getOrderDetail()
  }
  
  
  func getOrderDetail() {
    let params = SOAPParams(action: .Sale, path: .getAppOrderDetail)
    params.set(key: "orderId", value: orderId)
    params.set(key: "sessionId", value: sessionId)
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(MyOrderDetailModel.self, from: data) {
        if (model.Order_Info?.customer_id ?? "") != Defaults.shared.get(for: .clientId) {
          AlertView.show(message: "Sorry, this is not your payment QR code, please contact the staff", messageAlignment: .left) {
            self.navigationController?.popToRootViewController(animated: true)
          }
          return
        }
        self.headerView.model = model
        self.footerView.model = model
        self.orderDetail = model
      }
    } errorHandler: { e in
      
    }

  }
  
  @objc func confirmAction() {
    let pwd = Defaults.shared.get(for: .userModel)?.pay_password ?? ""
    CardDigitPinView.showView(pin: pwd) { pwd in
      self.payTOrder()
    } cancleHandler: {
      
    }

  }
    
  func payTOrder() {
    guard let orderDetail = orderDetail else {
      return
    }

    let mapParams = SOAPParams(action: .Sale, path: .payTOrder)
    
    let data = SOAPDictionary()
    
    let Order_Info = SOAPDictionary()
    
    Order_Info.set(key: "id", value: orderDetail.Order_Info?.id ?? "")
    Order_Info.set(key: "date", value: dateYMD)
    Order_Info.set(key: "total_recharge_discount", value: orderDetail.Order_Info?.total_new_recharge_discount ?? "")
    
    if let rewardId = orderDetail.Order_Info?.reward_id,!rewardId.isEmpty {
      Order_Info.set(key: "reward_id", value: rewardId)
      Order_Info.set(key: "reward_amout", value: orderDetail.Order_Info?.return_amount ?? "")
    }
    
    if orderDetail.pay_voucher.count > 0 {
      var gift_id = ""
      var gift_amount:CGFloat = 0
      orderDetail.pay_voucher.forEach({ e in
        if let client_gift_id = e.client_gift_id,let paid_amount = e.paid_amount?.cgFloat() {
          gift_id = client_gift_id
          gift_amount += paid_amount
        }
      })
      if !gift_id.isEmpty && gift_amount != 0 {
        Order_Info.set(key: "gift_id", value: gift_id)
        Order_Info.set(key: "gift_amout", value: gift_amount.string)
      }
      
    }
    
    Order_Info.set(key: "paid_amount", value: orderDetail.Order_Info?.paid_amount ?? "")
    Order_Info.set(key: "origin_paid_amount", value: orderDetail.Order_Info?.origin_paid_amount ?? "")
    
    Order_Info.set(key: "new_gift_voucher_amount", value: orderDetail.Order_Info?.new_gift_voucher_amount ?? "")
    Order_Info.set(key: "gift_voucher_amount", value: orderDetail.Order_Info?.gift_voucher_amount ?? "")
    
    Order_Info.set(key: "voucher_amount", value: orderDetail.Order_Info?.voucher_amount ?? "")
    Order_Info.set(key: "pay_by_balance", value: orderDetail.Order_Info?.pay_by_balance ?? "")
    Order_Info.set(key: "pay_by_gift", value: orderDetail.Order_Info?.pay_by_gift ?? "")
    Order_Info.set(key: "pay_by_service", value: orderDetail.Order_Info?.pay_by_service ?? "")
    Order_Info.set(key: "change", value: orderDetail.Order_Info?.change ?? "")
    
    Order_Info.set(key: "freight", value: orderDetail.Order_Info?.freight ?? "")
    
    Order_Info.set(key: "saleman_id", value: orderDetail.Order_Info?.saleman_id ?? "")
    Order_Info.set(key: "balance", value: orderDetail.Order_Info?.balance ?? "")
    Order_Info.set(key: "remark", value: orderDetail.Order_Info?.remark ?? "")
    
    Order_Info.set(key: "present_points", value: orderDetail.Order_Info?.present_points ?? "")
    
    Order_Info.set(key: "collection_method", value: 1)
    Order_Info.set(key: "post_code", value: "")
    Order_Info.set(key: "city", value: "")
    Order_Info.set(key: "street_name", value: "")
    Order_Info.set(key: "building_block_num", value: "")
    Order_Info.set(key: "unit_num", value: "")
    Order_Info.set(key: "address", value: "")
    
    Order_Info.set(key: "invoice_date", value: dateYMD)
    Order_Info.set(key: "due_date", value: dateYMD)
    Order_Info.set(key: "close_time", value: dateHMS)
    Order_Info.set(key: "status", value: 1)
    Order_Info.set(key: "is_from_app", value: 1)
    Order_Info.set(key: "qr", value: 1)

    data.set(key: "Order_Info", value: Order_Info.result, keyType: .string, valueType: .map(1))
    
    let Order_Lines = SOAPDictionary()
    
    guard let order_line_info = orderDetail.Order_Line_Info else { return }
    order_line_info.enumerated().forEach { i,order_line_info_item in
      let Order_Lines_0 = SOAPDictionary()
      let Order_Lines_Item = SOAPDictionary()
      
      Order_Lines_Item.set(key: "id", value: order_line_info_item.id ?? "")
      Order_Lines_Item.set(key: "salesmen_is", value: order_line_info_item.staff_id ?? "")
      Order_Lines_Item.set(key: "has_paid", value: "1")
      Order_Lines_Item.set(key: "pay_by_balance", value: "0")
      Order_Lines_Item.set(key: "new_recharge_discount", value:order_line_info_item.new_recharge_discount ?? "")
      
      let Pay_Voucher = SOAPDictionary()
      var pay_by_voucher = 0.cgFloat
      var pay_by_gift = 0.cgFloat
      
      if orderDetail.pay_voucher.count > 0 {
        orderDetail.pay_voucher.enumerated().forEach { i,pay_voucher_item in
          let client_voucher_type = pay_voucher_item.client_voucher_type ?? ""
          if pay_voucher_item.sale_order_line_id == order_line_info_item.id {
            if (client_voucher_type == "5" || client_voucher_type == "3") {
              
              pay_by_voucher += pay_voucher_item.paid_amount?.cgFloat() ?? 0
              
              let pay_voucher_item_dict = SOAPDictionary()
              pay_voucher_item_dict.set(key: "bought_voucher_id", value: pay_voucher_item.client_voucher_id ?? "")
              pay_voucher_item_dict.set(key: "paid_amount", value: pay_voucher_item.paid_amount ?? "")
              pay_voucher_item_dict.set(key: "voucher_type", value:client_voucher_type)
              pay_voucher_item_dict.set(key: "create_date", value: dateHMS)
              pay_voucher_item_dict.set(key: "is_present", value: "0")
              Pay_Voucher.set(key: i.string, value: pay_voucher_item_dict.result, keyType: .string, valueType: .map(1))
              
            } else if pay_voucher_item.client_gift_id != nil {
              pay_by_gift += pay_voucher_item.paid_amount?.cgFloat() ?? 0
            }
          }
         
        }
      }
      
      Order_Lines_Item.set(key: "pay_by_voucher", value: pay_by_voucher.string)
      Order_Lines_Item.set(key: "reward_discount", value: order_line_info_item.reward_discount ?? "")
      Order_Lines_Item.set(key: "pay_by_gift", value: pay_by_gift.string)
      Order_Lines_Item.set(key: "pay_by_service", value: "0")
      Order_Lines_Item.set(key: "collection_method", value: "2")
      Order_Lines_Item.set(key: "delivery_location_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      Order_Lines_Item.set(key: "has_delivered", value: "0")
      Order_Lines_Item.set(key: "delivery_time", value: "")
      Order_Lines_Item.set(key: "qr", value: "1")
      
      Order_Lines_0.set(key: "data", value: Order_Lines_Item.result, keyType: .string, valueType: .map(1))
      Order_Lines_0.set(key: "Pay_Voucher", value: Pay_Voucher.result, keyType: .string, valueType: .map(1))
     
      Order_Lines.set(key: i.string, value: Order_Lines_0.result, keyType: .string, valueType: .map(1))
    }
    data.set(key: "Order_Lines", value: Order_Lines.result, keyType: .string, valueType: .map(1))
    
    data.set(key: "payMethods", value: SOAPDictionary().result, keyType: .string, valueType: .map(1))
    
    let bookingTimeData = SOAPDictionary()
    bookingTimeData.set(key: "status", value: "6")
    bookingTimeData.set(key: "pay_date", value: dateYMD.appending(" 00:00:00"))
    bookingTimeData.set(key: "end_date", value: dateHMS)
    bookingTimeData.set(key: "has_paid", value: "1")
    
    data.set(key: "bookingTimesData", value: bookingTimeData.result, keyType: .string, valueType: .map(1))
    
    mapParams.set(key: "data", value: data.result, type: .map(1))
    
    let logData = SOAPDictionary()
    logData.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.id ?? "")
    mapParams.set(key: "logData", value: logData.result, type: .map(2))
    
#if DEBUG
    Toast.showLoading(withStatus: mapParams.path)
#endif
    NetworkManager().request(params: mapParams) { data in
     
      Toast.showSuccess(withStatus: "Payment successful")
      self.navigationController?.popToRootViewController(animated: true)
    } errorHandler: { e in
      
    }
  }
  
}
