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
    self.view.showSkeleton()
    let params = SOAPParams(action: .ClientProfile, path: .getTSlotHistoryForApp)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "start", value: page)
    params.set(key: "length", value: kPageSize)
    NetworkManager().request(params: params) { data in
      
      let dict = try? JSON.init(data: data).dictionaryValue
      if let items = dict?.values.map({ ($0.rawString() ?? "").data(using: .utf8) ?? Data() }).map({
        DecodeManager.decodeObjectByHandJSON(BookingCompleteModel.self, from: $0)
      }) {
        self.dataArray.append(contentsOf: items as [Any])
        self.endRefresh(items.count,emptyString: "You have no completed appointments")
      }else {
        self.endRefresh(.NoData, emptyString: "You have no completed appointments")
      }
      
      self.view.hideSkeleton()
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
      self.view.hideSkeleton()
    }

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
    CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 44 - kNavBarHeight - kTabBarHeight)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BookingCompletedCell.self)
    if dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row]  as? BookingCompleteModel
    }
    cell.selectionStyle = .none
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = BookingCompleteDetailController(complete: self.dataArray[indexPath.row] as! BookingCompleteModel)
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}
