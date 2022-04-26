//
//  ShopDetailReviewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/13.
//

import UIKit

class ShopDetailReviewController: BasePagingTableController {
  let bottomSheetHeight:CGFloat = 74 + kBottomsafeAreaMargin
  var headView = ShopDetailReviewHeadView()
  var productId = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshData()
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .Product, path: .getProductsReviews)
    params.set(key: "id", value: productId)
    params.set(key: "start", value: page)
    params.set(key: "offset", value: kPageSize)
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(ShopProductReviewModel.self, from: data) {
        self.dataArray.append(contentsOf: model.Reviews)
        if self.dataArray.count > 0 {
          self.tableView?.tableHeaderView = self.headView
          self.headView.size = CGSize(width: kScreenWidth, height: 180)
        }
        self.endRefresh(model.Reviews.count,emptyString: "No reviews yet")
        
        return
      }
      self.endRefresh()
      
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
    }

  }
  
  
  override func listViewFrame() -> CGRect {
    return CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 40 - kNavBarHeight)
  }
  
  override func createListView() {
    super.createListView()
    
    self.tableView?.register(nibWithCellClass: ShopProductReviewCell.self)
    self.tableView?.estimatedRowHeight = 100
    self.tableView?.rowHeight = UITableView.automaticDimension
    self.registRefreshFooter()
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ShopProductReviewCell.self)
    if self.dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? Reviews
    }
    cell.selectionStyle = .none
    return cell
  }
  
  func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
    return -(kScreenHeight * 0.5 - 40) * 0.75
  }
}
