//
//  BookingCompleteDetailView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/19.
//

import UIKit

class BookingCompleteDetailView: UIView,UITableViewDelegate,UITableViewDataSource {

  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var shadowView1: UIView!
  @IBOutlet weak var shadowView3: UIView!
  @IBOutlet weak var shadowView2: UIView!
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var subTotalLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var gstLabel: UILabel!
  @IBOutlet weak var pointsLabel: UILabel!
  
  @IBOutlet weak var discountLabel: UILabel!
  @IBOutlet weak var discountHeadLabel: UILabel!
  @IBOutlet weak var paymentMethodView: UIView!
  @IBOutlet weak var doctorAdviceLabel: UILabel!
  
  @IBOutlet weak var priceInfoVHCons: NSLayoutConstraint!
  @IBOutlet weak var paymentHCons: NSLayoutConstraint!
  @IBOutlet weak var tableHCons: NSLayoutConstraint!
  @IBOutlet weak var orderInfoVHCons: NSLayoutConstraint!
  @IBOutlet weak var totalTopCons: NSLayoutConstraint!
 
  var heightUpdateHandler:((CGFloat)->())?
  
  var complete:BookingCompleteModel? {
    didSet {
      guard let complete = complete else {
        return
      }
      if let date = complete.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss") {
        dateLabel.text = date.string(withFormat: "dd MMM yyyy,EEE - ").appending(date.timeString(ofStyle: .short))
      }
      
      locationLabel.text = complete.location_name
      layoutIfNeeded()
    }
  }
  
  var model:MyOrderDetailModel? {
    didSet {

      tableView.reloadData()
      pointsLabel.text = "(Points earned \(model?.Order_Info?.present_points ?? ""))"
      
      let showTotal:Float = model?.Order_Info?.total?.float() ?? 0
      let freight:Float = model?.Order_Info?.freight?.float() ?? 0
      totalLabel.text = (showTotal + freight).string.formatMoney().dolar
      
      var gst:Float = 0
      var discount:Float = 0
      model?.Order_Line_Info?.forEach({ item in
        
        discount += (item.new_recharge_discount?.float() ?? 0)
        
        discount += (item.reward_discount?.float() ?? 0)
        
        let paid_amount = item.paid_amount?.float() ?? 0
        let rate = item.rate?.float() ?? 0
        
        gst += paid_amount / (1 + (rate / 100))*(rate / 100);
        
      })
      
      gstLabel.text = "TOTAL(Inclusive of GST \(gst.string.formatMoney().dolar))"
      
      let subTotal = model?.Order_Info?.subtotal
      subTotalLabel.text = subTotal?.formatMoney().dolar ?? ""
      
      if discount == 0 {
        discountLabel.isHidden = true
        discountHeadLabel.isHidden = true
      }
      discountLabel.text = "-\(discount.string.formatMoney().dolar)"
      
      if model?.Paymethod_Info?.count ?? 0 > 0 {
        model?.Paymethod_Info?.forEach({ info in
          let view = BookingPaymentMethodView()
          let model = (title:info.name ?? "",money:"-" + (info.paid_amount?.formatMoney().dolar ?? ""))
          view.model = model
          paymentMethodView.addSubview(view)
        })
      }
      
      if model?.PayGift_Info?.count ?? 0 > 0 {
        model?.PayGift_Info?.forEach({ info in
          let view = BookingPaymentMethodView()
          let model = (title:info.name ?? "", money: "-" + (info.paid_amount?.formatMoney().dolar ?? ""))
          view.model = model
          paymentMethodView.addSubview(view)
        })
      }
      
      if model?.PayVoucher_Info?.count ?? 0 > 0 {
        var voucherDict:[String:Float] = [:]
        model?.PayVoucher_Info?.forEach({ info in
          let name = info.bought_voucher_id ?? ""
          let paid_amount = info.paid_amount?.float() ?? 0
          if voucherDict.keys.contains(name) {
            let new = (voucherDict[name] ?? 0) + paid_amount
            voucherDict[name] = new
          }else {
            voucherDict[name] = paid_amount
          }
        })
        let view = BookingPaymentMethodView()
        let model = (title:model?.PayVoucher_Info?.first?.name ?? "",money:"-" + (voucherDict.values.first?.string.formatMoney().dolar ?? ""))
        view.model = model
        paymentMethodView.addSubview(view)
      }
      
      let priceH = discount > 0 ? 144 : 120
      let totalTop = discount > 0 ? 40 : 16
      let tableH = model?.Order_Line_Info?.reduce(0, { $0 + $1.bookCompleteCellHeight }) ?? 0
      let paymentH = ((paymentMethodView.subviews.count - 2) * 16 + 50)
      let totalHeight = paymentH + priceH + 50 + tableH.int + 16
      heightUpdateHandler?(CGFloat(totalHeight))
      orderInfoVHCons.constant = totalHeight.cgFloat
      tableHCons.constant = tableH
      paymentHCons.constant = paymentH.cgFloat
      priceInfoVHCons.constant = priceH.cgFloat
      totalTopCons.constant = totalTop.cgFloat
      
      setNeedsLayout()
      layoutIfNeeded()
      
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView1.addLightShadow(by: 16)
    shadowView2.addLightShadow(by: 16)
    shadowView3.addLightShadow(by: 16)
    shadowView3.alpha = 0
    setupTableView()
  }
  
  
  func setupTableView() {
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .singleLine
    tableView.separatorColor = R.color.grayf2()
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    tableView.isScrollEnabled = false
    
    tableView.register(cellWithClass: BookingComplteItemCell.self)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.model?.Order_Line_Info?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if self.model?.Order_Line_Info?.count ?? 0 > 0 {
      return self.model?.Order_Line_Info?[indexPath.row].bookCompleteCellHeight ?? 0
    }
    
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BookingComplteItemCell.self)
    if self.model?.Order_Line_Info?.count ?? 0 > 0 {
      cell.model = self.model?.Order_Line_Info?[indexPath.row]
    }
    cell.selectionStyle = .none
    return cell
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topRight,.topLeft], radii: 16)
    
    let methodViews =  paymentMethodView.subviews.filter({ $0 is BookingPaymentMethodView })
    if methodViews.count == 0 { return }
    for i in 0...(methodViews.count - 1) {
      let view = methodViews[i]
      view.frame = CGRect(x: 0, y: 50 + i * 16 , width: Int(kScreenWidth) - 48, height: 16)
    }
  }
  
}

class BookingComplteItemCell: UITableViewCell {

  var productNameLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size:12)
    label.numberOfLines = 0
    label.text = "Wellness Massage (60 min)"
  }
  var priceLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size:12)
    label.text = "$180.00"
    label.textAlignment = .right
  }
  
  
  var model:OrderLineInfo? {
    didSet {
      productNameLabel.text = model?.name
      priceLabel.text = model?.price?.formatMoney().dolar
      
    }
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(productNameLabel)
    contentView.addSubview(priceLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    priceLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(16)
      make.centerY.equalToSuperview()
      make.width.equalTo(80)
    }
    
    productNameLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
      make.right.equalTo(priceLabel.snp.left).offset(-8)
    }
  }
}

class BookingPaymentMethodView: UIView {
  
  var typeLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 12)
    label.textAlignment = .left
  }
  var moneyLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 12)
    label.textAlignment = .right
  }
  var model:(title:String,money:String)? {
    didSet {
      typeLabel.text = model?.title
      moneyLabel.text = model?.money
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(typeLabel)
    addSubview(moneyLabel)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    typeLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
    }
    moneyLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-16)
      make.centerY.equalToSuperview()
    }
  }
}
