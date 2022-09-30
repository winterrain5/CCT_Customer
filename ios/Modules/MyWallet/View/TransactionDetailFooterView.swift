//
//  TransactionDetailFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/4.
//

import UIKit

class TransactionDetailFooterView: UIView {

  @IBOutlet weak var otherInfoContentView: UIView!
  @IBOutlet weak var totalPriceLabel: UILabel!
  @IBOutlet weak var pointsLabel: UILabel!
  @IBOutlet weak var gstLabel: UILabel!
  @IBOutlet weak var paymentMethodContentVIew: UIView!
  @IBOutlet weak var otherInfoContentHCons: NSLayoutConstraint!
  var model:MyOrderDetailModel? {
    didSet {
      pointsLabel.text = "(Points earned \(model?.Order_Info?.present_points ?? ""))"
      
      let showTotal:Float = model?.Order_Info?.total?.float() ?? 0
      let freight:Float = model?.Order_Info?.freight?.float() ?? 0
      totalPriceLabel.text = (showTotal + freight).string.formatMoney().dolar
      
      var gst:Float = 0
      var discount:Float = 0
      model?.Order_Line_Info?.forEach({ item in
        
        discount += (item.new_recharge_discount?.float() ?? 0)
        
        discount += (item.reward_discount?.float() ?? 0)
        
        let paid_amount = item.paid_amount?.float() ?? 0
        let rate = item.rate?.float() ?? 0
        
        gst += paid_amount / (1 + (rate / 100))*(rate / 100);
        
      })
      
      if gst == 0 {
        gstLabel.text = ""
      } else {
        if model?.Order_Info?.paid_amount?.float() ?? 0 > 0 { // 现金支付 显示扣税
          gstLabel.text = "(Inclusive of GST \(gst.string.formatMoney().dolar))"
        }else {
          gstLabel.text = ""
        }
      }
      
      let subTotal = model?.Order_Info?.subtotal
      let view1 = TransactionDetailFooterOtherInfoView()
      view1.model = (title:"Sub Total",money:subTotal?.formatMoney().dolar ?? "")
      otherInfoContentView.addSubview(view1)
      
      if discount > 0 {
        let view2 = TransactionDetailFooterOtherInfoView()
        view2.model = (title:"Discount",money:"-" + discount.string.formatMoney().dolar)
        otherInfoContentView.addSubview(view2)
      }
     
      if freight == 0 {
        if (model?.Order_Info?.address?.isEmpty ?? true) {
          var isShowLocal = false
          guard let ordeLineInfo = model?.Order_Line_Info else { return }
          for info in ordeLineInfo {
            if info.product_category == "1" || info.product_category == "5" {
              isShowLocal = true
              break
            }
          }
          if isShowLocal {
            let view3 = TransactionDetailFooterOtherInfoView()
            view3.model = (title:"Self Collection @ \(ordeLineInfo.first?.delivery_location_name ?? "")",money:"$0.00")
            otherInfoContentView.addSubview(view3)
          }
        }
      }else {
        let view3 = TransactionDetailFooterOtherInfoView()
        view3.model = (title:"Local Delivery",money:freight.string.formatMoney().dolar)
        otherInfoContentView.addSubview(view3)
      }
      
      if model?.Paymethod_Info?.count ?? 0 > 0 {
        model?.Paymethod_Info?.forEach({ info in
          let view = TransactionDetailFooterPaymentMethodView()
          let model = (title:info.name ?? "",money:"-" + (info.paid_amount?.formatMoney().dolar ?? ""))
          view.model = model
          paymentMethodContentVIew.addSubview(view)
        })
      }
      
      if model?.PayGift_Info?.count ?? 0 > 0 {
        model?.PayGift_Info?.forEach({ info in
          let view = TransactionDetailFooterPaymentMethodView()
          let model = (title:info.name ?? "", money: "-" + (info.paid_amount?.formatMoney().dolar ?? ""))
          view.model = model
          paymentMethodContentVIew.addSubview(view)
        })
      }
      
      if model?.PayVoucher_Info?.count ?? 0 > 0 {
        var voucherArray: [[String:Float]] = []
        model?.PayVoucher_Info?.enumerated().forEach({ i,info in
          let name = info.name ?? ""
          let paid_amount = info.paid_amount?.float() ?? 0
          if voucherArray.count >= 1 {
            guard var last = voucherArray.last else { return }
            let preName = last.keys.first ?? ""
            let preValue = last.values.first ?? 0
            if name == preName {
              last[name] = paid_amount + preValue
              voucherArray.removeLast()
              voucherArray.append(last)
            }else {
              var voucherDict:[String:Float] = [:]
              voucherDict[name] = paid_amount
              voucherArray.append(voucherDict)
            }
          }else {
            var voucherDict:[String:Float] = [:]
            voucherDict[name] = paid_amount
            voucherArray.append(voucherDict)
          }
         
        })
        
        voucherArray.enumerated().forEach { i,dict in
          let view = TransactionDetailFooterPaymentMethodView()
          let model = (title:dict.keys.first ?? "", money:"-" + (dict.values.first?.string.formatMoney().dolar ?? ""))
          view.model = model
          paymentMethodContentVIew.addSubview(view)
        }
       
      }
      
      let otherInfoH = (otherInfoContentView.subviews.count - 1) * 30 + 20
      
      let totalHeight = otherInfoH + paymentMethodContentVIew.subviews.count * 38 + 70 + 86
      heightUpdateHandler?(CGFloat(totalHeight))
      
      otherInfoContentHCons.constant = otherInfoH.cgFloat
      setNeedsLayout()
      layoutIfNeeded()
      
      hideSkeleton()
    }
    
  }
  var heightUpdateHandler:((CGFloat)->())?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    showSkeleton()
  
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if otherInfoContentView.subviews.count > 0 {
      for i in 0...(otherInfoContentView.subviews.count - 1) {
        let view = otherInfoContentView.subviews[i]
        view.frame = CGRect(x: 0, y: 10 + (i - 1) * 30 , width: Int(kScreenWidth) - 48, height: 30)
      }
    }
    
    if paymentMethodContentVIew.subviews.count > 0 {
      for i in 0...(paymentMethodContentVIew.subviews.count - 1) {
        let view = paymentMethodContentVIew.subviews[i]
        view.frame = CGRect(x: 0, y: 53 + (i - 1) * 38 , width: Int(kScreenWidth) - 48, height: 38)
      }
    }
   
  }
}

class TransactionDetailFooterOtherInfoView:UIView {
  var titleLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name:.AvenirNextRegular,size: 14)
    label.text = "Sub Total"
  }
  var moneyLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size:16)
    label.text = "$160"
    label.textAlignment = .right
  }
  var model:(title:String,money:String)? {
    didSet {
      titleLabel.text = model?.title
      moneyLabel.text = model?.money
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)
    addSubview(moneyLabel)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    moneyLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(24)
      make.centerY.equalToSuperview()
      make.width.equalTo(80)
      
    }
    titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalToSuperview()
      make.right.equalTo(moneyLabel.snp.left).offset(-8)
    }
    
  }
}

class TransactionDetailFooterPaymentMethodView: UIView {
  var button = UIButton().then { button in
    button.titleForNormal = "MasterCard 1234 - $48.00"
    button.titleLabel?.font = UIFont(name:.AvenirNextRegular,size:16)
    button.titleColorForNormal = R.color.black333()
    button.imageForNormal = R.image.transaction_payment_master()
  }
  var model:(title:String,money:String)? {
    didSet {
      button.imageForNormal = R.image.transaction_payment_other()
      button.titleForNormal = "\(model?.title ?? "") \(model?.money ?? "")"
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(button)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    button.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalToSuperview()
    }
  }
}
