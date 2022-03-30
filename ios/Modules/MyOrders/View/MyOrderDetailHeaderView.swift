//
//  MyOrderDetailHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class MyOrderDetailHeaderView: UIView,UITableViewDelegate,UITableViewDataSource {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  var cellHeight:CGFloat = 0
  var updateHeightHandler:((CGFloat)->())?
  var model:MyOrderDetailModel? {
    didSet {
      guard let model = model else {
        return
      }
      
      tableView.reloadData()
      var shouldLeaveReview:Bool = false
      model.Order_Line_Info?.forEach({ info in
        shouldLeaveReview = info.should_leavea_review ?? false
      })
      if status == 1 {
        cellHeight = shouldLeaveReview ? 150 : 92
      }else {
        cellHeight = 92
      }
      let total:CGFloat = 236.cgFloat + (model.Order_Line_Info?.count ?? 0).cgFloat * cellHeight
      updateHeightHandler?(total)
    }
  }
  var leaveReviewPoints:String = ""
  var status:Int = 0 {
    didSet {
      
      if status == 0 {
        statusLabel.text = "In Progress"
        statusLabel.backgroundColor = R.color.theamBlue()
      }
      if status == 1 {
        statusLabel.text = "Completed"
        statusLabel.backgroundColor = UIColor(hexString: "#38B46C")
      }
      if status == 2 {
        statusLabel.text = "Cancelled"
        statusLabel.backgroundColor = UIColor(hexString: "#E0E0E0")
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    tableView.isScrollEnabled = false
    tableView.register(nibWithCellClass: ProductItemCell.self)
    tableView.register(nibWithCellClass: ProductCompleteItemCell.self)
    
    tableView.tableHeaderView = UIView()
    tableView.tableFooterView = UIView()
    
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView.separatorColor = UIColor(hexString: "#E0E0E0")
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = UIColor(hexString: "#FAF3EB")
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let count =  model?.Order_Line_Info?.count else {
      return 0
    }
    return count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let count = self.model?.Order_Line_Info?.count ?? 0
    var model:OrderLineInfo?
    if count > 0 {
      model = self.model?.Order_Line_Info?[indexPath.row]
    }
    let shouldLeaveaReview = model?.should_leavea_review ?? false
    if status == 1 && shouldLeaveaReview {
      return  150
    }else {
      return 92
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let count = self.model?.Order_Line_Info?.count ?? 0
    var model:OrderLineInfo?
    if count > 0 {
      model = self.model?.Order_Line_Info?[indexPath.row]
      model?.leave_review_points = leaveReviewPoints
    }
    let shouldLeaveaReview = model?.should_leavea_review ?? false
    if status == 1 && shouldLeaveaReview {
      
      let cell = tableView.dequeueReusableCell(withClass: ProductCompleteItemCell.self)
      if count > 0 {
        cell.model = model
        cell.separatorInset = indexPath.row == (count - 1) ? UIEdgeInsets(top: 0, left: kScreenWidth, bottom: 0, right: 0) : .zero
      }
      cell.leaveReviewHandler = { [weak self] model in
        guard let `self` = self else { return }
        if model.product_category == "2" {
          let vc = FeedbackFormController(bookingTimeId: model.source_id ?? "")
          UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
        }else {
          ProductLeaveReviewSheetView().showView(from: (UIViewController.getTopVC()?.view)!, with: self.model, leaveReviewPoints: self.leaveReviewPoints)
        }
        
      }
      return cell
      
    } else  {
      let cell = tableView.dequeueReusableCell(withClass: ProductItemCell.self)
      if count > 0 {
        cell.model = model
        cell.separatorInset = indexPath.row == (count - 1) ? UIEdgeInsets(top: 0, left: kScreenWidth, bottom: 0, right: 0) : .zero
      }
      return cell
    }
    
  }
}
