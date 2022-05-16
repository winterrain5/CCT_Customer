//
//  BookingCompletedController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/13.
//

import UIKit

class BookingCompletedController: BasePagingTableController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshData()
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .ClientProfile, path: .getTSlotHistoryForApp)
    
  }
  
  override func createListView() {
    super.createListView()
    
    self.cellIdentifier = BookingCompletedCell.className
    self.tableView?.isSkeletonable = true
    self.view.isSkeletonable = true
    
    self.tableView?.register(nibWithCellClass: BookingCompletedCell.self)
    self.tableView?.estimatedRowHeight = 180
    self.tableView?.rowHeight = UITableView.automaticDimension
    
    self.tableView?.separatorStyle = .singleLine
    self.tableView?.separatorColor = R.color.line()
    self.tableView?.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
  }
  
  override func listViewFrame() -> CGRect {
    CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 100 - kNavBarHeight - kTabBarHeight)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BookingCompletedCell.self)
    return cell
  }
}
