//
//  MyOrdersController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/8.
//

import UIKit

class MyOrdersController: BaseTableController {
  
  private var headerView = MyOrderHeaderView()
  private var status:Int = 0
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = "My Orders"
    self.view.addSubview(headerView)
    headerView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: 76)
    headerView.statusDidClickHandler = { [weak self] status in
      self?.status = status
      self?.loadNewData()
    }
    
    refreshData()
  }
  
  override func refreshData() {
    var path:API!
    var emptyStr:String = ""
    if status == 0 {
      path = .getInProgressOrders
      emptyStr = "You have not ordered anything recently"
    }
    if status == 1 {
      path = .getCompletedOrders
      emptyStr = "You have no completed order recently"
    }
    if status == 2 {
      path = .getCancelledInvoices
      emptyStr = "You have no cancelled order recently"
    }
    let params = SOAPParams(action: .ClientProfile, path: path)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeByCodable([MyOrderModel].self, from: data) {
        self.dataArray = models
      }
      if self.dataArray.count == 0 {
        self.endRefresh(.NoData, emptyString: emptyStr)
        return
      }
      self.endRefresh()
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }

  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.register(nibWithCellClass: MyOrderListCell.self)
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 80
    
    registRefreshHeader()
  }
  
  override func listViewFrame() -> CGRect {
    CGRect(x: 0, y: kNavBarHeight + 76, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - 76)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: MyOrderListCell.self)
    if dataArray.count > 0 {
      cell.model = dataArray[indexPath.row] as? MyOrderModel
    }
    cell.selectionStyle = .none
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model = self.dataArray[indexPath.row] as! MyOrderModel
    let vc = MyOrderDetailController(status: status,orderModel: model)
    self.navigationController?.pushViewController(vc)
    
  }
}
