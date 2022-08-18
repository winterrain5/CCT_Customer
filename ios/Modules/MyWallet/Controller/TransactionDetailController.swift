//
//  TransactionDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/4.
//

import UIKit

class TransactionDetailController: BaseTableController {
  
  var headerView = TransactionDetailHeaderView()
  var footerView = TransactionDetailFooterView.loadViewFromNib()
  var transactionModel:WalletTranscationModel!
  var detailModel:MyOrderDetailModel?
  
  convenience init(transactionModel:WalletTranscationModel) {
    self.init()
    self.transactionModel = transactionModel
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshData()
  }
  
  override func refreshData() {
    
    if transactionModel.type == "5" {
      getOrderDetails(url: .getHistoryCheckoutDetails)
    }else {
      getOrderDetails(url: .getHistoryOrderDetails)
    }

  }
  
  func getOrderDetails(url:API) {
    let params = SOAPParams(action: .Sale, path: url)
    params.set(key: "orderId", value: transactionModel.id ?? "")
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(MyOrderDetailModel.self, from: data) {
        self.detailModel = model
        self.headerView.model = model
        self.footerView.model = model
        self.tableView?.reloadData()
      }else {
        Toast.showError(withStatus: "Decode MyOrderDetailModel Failed")
      }
    } errorHandler: { e in
      
    }

  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.grayf2()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    
    tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: 94)
    
    tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 400)
    footerView.heightUpdateHandler = { [weak self] height in
      self?.footerView.height = height
      self?.tableView?.tableFooterView = self?.footerView
    }
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 80
    
    tableView?.register(cellWithClass: TransactionDetailCell.self)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.detailModel?.Order_Line_Info?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if self.detailModel?.Order_Line_Info?.count ?? 0 > 0 {
      return self.detailModel?.Order_Line_Info?[indexPath.row].transactionDetailCellHeight ?? 0
    }
    
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: TransactionDetailCell.self)
    if self.detailModel?.Order_Line_Info?.count ?? 0 > 0 {
      cell.model = self.detailModel?.Order_Line_Info?[indexPath.row]
    }
    return cell
  }
  
}

class TransactionDetailHeaderView: UIView {
  var invoiceLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:24)
    label.text = "#INVXXXXXX1"
    label.isSkeletonable = true
  }
  var dateLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name:.AvenirNextRegular,size:16)
    label.text = "15 Dec 2020, Friday"
    label.isSkeletonable = true
  }
  var model:MyOrderDetailModel? {
    didSet {
      invoiceLabel.text = "#" + (model?.Order_Info?.invoice_no ?? "")
      dateLabel.text = model?.Order_Info?.date?.date(withFormat: "yyyy-MM-dd")?.string(withFormat: "dd MMM yyyy,EEEE")
      hideSkeleton()
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(invoiceLabel)
    addSubview(dateLabel)
    isSkeletonable = true
    showSkeleton()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    invoiceLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(32)
      make.height.equalTo(36)
    }
    dateLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(invoiceLabel.snp.bottom)
      make.height.equalTo(24)
    }
  }
}

class TransactionDetailCell: UITableViewCell {
  var productNameLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size:14)
    label.numberOfLines = 0
    label.lineBreakMode = .byCharWrapping
    label.text = "Wellness Massage (60 min)"
  }
  var priceLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size:14)
    label.text = "$180.00"
    label.textAlignment = .right
  }
  var discountHeadLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name:.AvenirNextRegular,size:14)
    label.text = "Discount"
    label.numberOfLines = 0
    label.lineBreakMode = .byCharWrapping
  }
  var discountLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name:.AvenirNextRegular,size:14)
    label.text = "-$180.00"
    label.textAlignment = .right
  }
  
  var model:OrderLineInfo? {
    didSet {
      
      guard let model = model else { return }
      if let qty = model.qty?.float(),qty > 1 {
        productNameLabel.text = model.name?.appending(" x").appending(qty.int.string)
        priceLabel.text = ((model.retail_price?.float() ?? 0) * qty).string.formatMoney().dolar
      }else {
        productNameLabel.text = model.name
        priceLabel.text = model.price?.formatMoney().dolar
      }
      
      

      if model.totalDiscount > 0 {
        discountLabel.text = "-" + model.totalDiscount.string.formatMoney().dolar
        discountHeadLabel.text = model.discountName
        discountLabel.isHidden = false
        discountHeadLabel.isHidden = false
      }else {
        discountLabel.isHidden = true
        discountHeadLabel.isHidden = true
      }
      
    }
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(productNameLabel)
    contentView.addSubview(priceLabel)
    contentView.addSubview(discountHeadLabel)
    contentView.addSubview(discountLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    priceLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(24)
      make.top.equalToSuperview().offset(21)
      make.width.equalTo(80)
    }
    
    productNameLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(21)
      make.right.equalTo(priceLabel.snp.left).offset(-8)
    }
  
    discountHeadLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-110)
      make.top.equalTo(productNameLabel.snp.bottom).offset(12)
      
    }
    discountLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(24)
      make.width.equalTo(80)
      make.top.equalTo(discountHeadLabel)
    }
  }
}
