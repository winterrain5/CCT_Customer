//
//  HomeServiceFooterView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/9/29.
//

import UIKit
import RxSwift

class HomeServiceFooterView: UIView {

  var footerItems: [HomeServiceFooterItemView] = []
  var updateHeightHandler: ((CGFloat)->())?
  var model:MyOrderDetailModel? {
    didSet {
      guard let model = model else {
        return
      }
      let total = model.Order_Line_Info?.reduce(0, { $0 + ($1.qty?.cgFloat() ?? 0) })
      let totalItem = HomeServiceFooterItemView(key: "Total Items", value: total?.string ?? "0")
      footerItems.append(totalItem)
      
      let subTotal = (model.Order_Info?.subtotal ?? "0").formatMoney().dolar
      let subTotalItem = HomeServiceFooterItemView(key: "Sub Total",value: subTotal)
      footerItems.append(subTotalItem)
      
      var discount: CGFloat = 0
      var reward: CGFloat = 0
      if model.Order_Line_Info?.count ?? 0 > 0 {
        model.Order_Line_Info?.enumerated().forEach({ i,e in
          discount += (e.new_recharge_discount?.cgFloat() ?? 0)
          reward += (e.reward_discount?.cgFloat() ?? 0)
        })
        
        if discount != 0 {
          let discountItem = HomeServiceFooterItemView(key: "Discount", value: "-\(discount.string.formatMoney().dolar)")
          footerItems.append(discountItem)
        }
        
        if reward != 0 {
          let rewardItem = HomeServiceFooterItemView(key: "Reward", value: "-\(reward.string.formatMoney().dolar)")
          footerItems.append(rewardItem)
        }
      }
      
      var coupon: CGFloat = 0
      var package: CGFloat = 0
      if model.pay_voucher.count > 0 {
        model.pay_voucher.enumerated().forEach { i,e in
          if e.client_gift_id != nil {
            coupon += e.paid_amount?.cgFloat() ?? 0
          } else  {
            let client_voucher_type = e.client_voucher_type ?? ""
            if !client_voucher_type.isEmpty && (client_voucher_type == "3" ||  client_voucher_type == "4") {
              package +=  e.paid_amount?.cgFloat() ?? 0
            }
          }
        }
        if coupon != 0 {
          let couponItem = HomeServiceFooterItemView(key: "Coupon", value: "-\(coupon.string.formatMoney().dolar)")
          footerItems.append(couponItem)
        }
        
        if package != 0 {
          let packageItem = HomeServiceFooterItemView(key: "Package", value: "-\(package.string.formatMoney().dolar)")
          footerItems.append(packageItem)
        }
      }
      
      let freight = model.Order_Info?.freight?.cgFloat() ?? 0
      if freight > 0 {
        let freightItem = HomeServiceFooterItemView(key: "freight", value: freight.string.formatMoney().dolar)
        footerItems.append(freightItem)
      }
      
      
      var showTotal = model.Order_Info?.total?.cgFloat() ?? 0
      showTotal = showTotal + freight - coupon - package
      var gst: CGFloat = 0
      let paid_amount: CGFloat = model.Order_Info?.paid_amount?.cgFloat() ?? 0
      let rate: CGFloat = model.Order_Line_Info?.first?.rate?.cgFloat() ?? 0
      gst = paid_amount / (1 + (rate / 100))*(rate / 100)
      var showTotalKey = "Total"
      if gst > 0 {
        showTotalKey = "Total(Inclusive GST \(gst.string.formatMoney().dolar)"
      }
      let showTotalItem = HomeServiceFooterItemView(key: showTotalKey, value: showTotal.string.formatMoney().dolar, isLast: true)
      footerItems.append(showTotalItem)
      
      footerItems.forEach { item in
        self.addSubview(item)
      }
      
      footerItems.enumerated().forEach { i,e in
        let height = 30.cgFloat
        let width = kScreenWidth - 80
        let mt = 20.cgFloat
        let space = 8.cgFloat
        e.frame = CGRect(x: 16, y: mt + i.cgFloat * (height + space) , width: width, height: height)
      }
      layoutIfNeeded()
      
      updateHeightHandler?((footerItems.last?.frame.maxY ?? 0) + 20)
      
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
   
  }

}

class HomeServiceFooterItemView: UIView {

  private var key: String = ""
  private var value: String = ""
  private var isLast: Bool = false
  private lazy var keyLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    if isLast {
      label.font = UIFont(name: .AvenirNextDemiBold, size: 14)
    } else {
      label.font = UIFont(name: .AvenirNextRegular, size: 14)
    }
  }
  private lazy var valueLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    if isLast {
      label.font = UIFont(name: .AvenirNextDemiBold, size: 14)
    } else {
      label.font = UIFont(name: .AvenirNextRegular, size: 14)
    }
  }
  
  convenience init(key: String, value: String, isLast: Bool = false) {
    self.init(frame: .zero)
    self.key = key
    self.value = value
    self.isLast = isLast
    addSubview(keyLabel)
    addSubview(valueLabel)
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    keyLabel.text = self.key
    valueLabel.text = self.value
    keyLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
    }
    valueLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-16)
      make.centerY.equalToSuperview()
    }
  }
}
