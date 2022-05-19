//
//  BookingUpcomingController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/13.
//

import UIKit

class BookingUpcomingController: BasePagingTableController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadNewData()
  }
  
  override func refreshData() {
    if isFirstLoad { self.view.showSkeleton() }
    let params = SOAPParams(action: .ClientProfile, path: .getTUpcomingAppointments)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "startDateTime", value: Date().tomorrow.string(withFormat: "yyyy-MM-dd").appending(" 00:00:00"))
    params.set(key: "wellnessType", value: "")
    params.set(key: "start", value: page)
    params.set(key: "length", value: kPageSize)
    NetworkManager().request(params: params) { data in
     
      if let models = DecodeManager.decodeArrayByHandJSON(BookingUpComingModel.self, from: data) {
        self.dataArray.append(contentsOf: models)
        self.endRefresh(models.count,emptyString: "You have no upcoming appointments")
        self.view.hideSkeleton()
        return
      }
      self.endRefresh(.NoData, emptyString: "You have no upcoming appointments")
      self.view.hideSkeleton()
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
      self.view.hideSkeleton()
    }

  }
  
  override func createListView() {
    super.createListView()
    
    self.cellIdentifier = BookingUpComingCell.className
    self.tableView?.isSkeletonable = true
    self.view.isSkeletonable = true
    
    self.tableView?.register(nibWithCellClass: BookingUpComingCell.self)
    
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
    160
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BookingUpComingCell.self)
    if dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? BookingUpComingModel
    }
    cell.selectionStyle = .none
    return cell
  }
   
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = BookingUpComingDetailController(upcoming: self.dataArray[indexPath.row] as! BookingUpComingModel)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> UIImage! {
    return R.image.booking_button()!
  }
  
  func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
    cancleBooking()
  }
  
  func cancleBooking() {
    let params = SOAPParams(action: .Client, path: .getClientCancelCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      let count = JSON.init(from: data)?["cancel_count"].rawString()?.int ?? 0
      if count > 3 {
        AlertView.show(message: "If you delay cancelling more than 3 times, your in app reservation permission will be suspended.")
      }else {
        SelectTypeOfServiceSheetView.show()
      }
     
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
}
