//
//  ProductLeaveReviewSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/21.
//

import UIKit
class ProductLeaveReviewSheetView: UIView {
  var contentView = ProductLeaveReviewSheetContentView.loadViewFromNib()
  let contentHeight:CGFloat = kScreenHeight - 120 - kBottomsafeAreaMargin
  var scrolview = UIScrollView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    contentView.submitCompleteHandler = { [weak self] in
      self?.dismiss()
    }
    
    scrolview.contentSize = CGSize(width: kScreenWidth, height: contentHeight)
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    scrolview.addGestureRecognizer(tap)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  @objc func tapAction(_ ges:UIGestureRecognizer) {
    let location = ges.location(in: scrolview)
    if location.y < (kScreenHeight - contentHeight) {
     dismiss()
    }
  }
  
  func dismiss() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.contentView.frame.origin.y = kScreenHeight
      self.backgroundColor = .clear
    } completion: { flag in
      self.removeFromSuperview()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    scrolview.frame = self.bounds
    contentView.size = CGSize(width: kScreenWidth, height: contentHeight)
  }
  
  
  func showView(from spView:UIView,with detail:MyOrderDetailModel?,leaveReviewPoints:String) {
    self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    spView.addSubview(self)
    
    self.contentView.models = detail?.Order_Line_Info ?? []
    self.contentView.detailModel = detail
    self.contentView.leaveReviewPoints = leaveReviewPoints
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
      self.contentView.frame.origin.y = kScreenHeight - self.contentHeight
    } completion: { flag in
      
    }
  }

}

class ProductLeaveReviewSheetContentView: UIView,UITableViewDelegate,UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var submitButton: UIButton!
  private let footerView = ProductLeaveReviewSheetFooterView.loadViewFromNib()
  private var review:String = ""
  private var starCount:String = ""
  
  var leaveReviewPoints:String = "" {
    didSet {
      footerView.leaveReviewPoints = leaveReviewPoints
    }
  }

  var models:[OrderLineInfo] = [] {
    didSet {
    
      tableView.reloadData()
     
    }
  }
  
  var submitCompleteHandler:(()->())?
  
  var detailModel:MyOrderDetailModel?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    
    tableView.isScrollEnabled = true
    tableView.register(nibWithCellClass: ProductItemCell.self)
    
    tableView.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: kScreenHeight)
    footerView.textFieldDidEditingHandler = { [weak self] text in
      self?.submitButton.backgroundColor = text.isEmpty ? UIColor(hexString: "e0e0e0") : R.color.theamRed()
      self?.submitButton.isEnabled = !text.isEmpty
      self?.review = text
    }
    footerView.starContentView.callback = { [weak self] count in
      self?.starCount = count.string
    }
    
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView.separatorColor = UIColor(hexString: "#E0E0E0")
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = .white
    
    submitButton.backgroundColor = UIColor(hexString: "#E0E0E0")
    submitButton.isEnabled = false
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return models.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 92
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var model:OrderLineInfo?
    if models.count > 0 {
      model = models[indexPath.row]
      model?.leave_review_points = leaveReviewPoints
    }
    let cell = tableView.dequeueReusableCell(withClass: ProductItemCell.self)
    if models.count > 0 {
      cell.model = model
      cell.contentView.backgroundColor = .white
      cell.separatorInset = indexPath.row == (models.count - 1) ? UIEdgeInsets(top: 0, left: kScreenWidth, bottom: 0, right: 0) : .zero
    }
    return cell
    
  }

  @IBAction func submitButtonAction(_ sender: LoadingButton) {
    let params = SOAPParams(action: .Sale, path: .saveProductReview)
    if models.count == 0 { return }
    guard let model = models.first else { return }
    params.set(key: "productId", value: model.product_id ?? "")
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    let data = SOAPDictionary()
    data.set(key: "rating", value: starCount)
    data.set(key: "review_content", value: review)
    data.set(key: "sales_order_id", value: detailModel?.Order_Info?.id ?? "")
    data.set(key: "sales_order_line_id", value: model.id ?? "")
    
    data.set(key: "is_present_points", value: "0")
//    if model.has_leaved_review == 0 {
//      data.set(key: "is_present_points", value: "1")
//      data.set(key: "present_points", value: leaveReviewPoints)
//    }else {
//      data.set(key: "is_present_points", value: "0")
//      data.set(key: "present_points", value: "0")
//    }
    
    params.set(key: "data", value: data.result, type:  .map(1))
    
    sender.startAnimation()
    NetworkManager().request(params: params) { data in
      Toast.showSuccess(withStatus: "Review Success")
      sender.stopAnimation()
      NotificationCenter.default.post(name: NSNotification.Name.reviewOrderComplete, object: nil)
      self.submitCompleteHandler?()
    } errorHandler: { e in
      sender.stopAnimation()
      self.submitCompleteHandler?()
    }

  }
 
}

