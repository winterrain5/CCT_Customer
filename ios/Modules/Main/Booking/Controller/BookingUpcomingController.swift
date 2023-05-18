//
//  BookingUpcomingController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/13.
//

import UIKit

class BookingUpcomingController: BasePagingTableController {

  var todayH:CGFloat = 0
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    NotificationCenter.default.addObserver(forName: .bookingTodayLoaded, object: nil, queue: .main) { noti  in
      let todayH = noti.object as? CGFloat ?? 0
      self.todayH = todayH
      self.loadNewData()
    }
    
    NotificationCenter.default.addObserver(forName:.bookingDataChanged, object: nil, queue: .main) { _ in
      self.loadNewData()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()


  }

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  override func refreshData() {
    if isFirstLoad { self.view.showSkeleton() }
    let params = SOAPParams(action: .ClientProfile, path: .getTUpcomingAppointments)
//    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "clientId", value: 162043)
    params.set(key: "startDateTime", value: Date().tomorrow.string(withFormat: "yyyy-MM-dd").appending(" 00:00:00"))
    params.set(key: "wellnessType", value: "")
    params.set(key: "start", value: page)
    params.set(key: "length", value: kPageSize)
    NetworkManager().request(params: params) { data in
     
      if var models = DecodeManager.decodeArrayByHandJSON(BookingUpComingModel.self, from: data),models.count > 0 {
        models.sort(by: {( $0.therapy_start_date.dateTime?.unixTimestamp ?? 0) < ($1.therapy_start_date.dateTime?.unixTimestamp ?? 0) })
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
    
    self.registRefreshFooter()
    
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
    if dataArray.count > 0 && dataArray.count >= (indexPath.row + 1) {
      let model = dataArray[indexPath.row] as! BookingUpComingModel
      return model.cellHeight
    }
    return 180
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
    if self.dataArray.count == 0 { return }
    let model = self.dataArray[indexPath.row] as! BookingUpComingModel
    if model.wellness_treatment_type == "2" {
      let vc = BookingUpcomingTreatmentController(upcoming: model)
      self.navigationController?.pushViewController(vc, animated: true)
    }else {
      let vc = BookingUpComingWellnessController(upcoming: model)
      self.navigationController?.pushViewController(vc, animated: true)
    }
    
  
  }

  func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> UIImage! {
    return R.image.booking_button()!
  }
  
  func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
    getClientCancelCount()
  }
  
  func getClientCancelCount() {
    let params = SOAPParams(action: .Client, path: .getClientCancelCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      let count = JSON.init(from: data)?["cancel_count"].rawString()?.int ?? 0
      if count >= 3 {
        AlertView.show(message: "If you delay cancelling more than 3 times, your in app reservation permission will be suspended.")
      }else {
        SelectTypeOfServiceSheetView.show()
      }
     
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
  
  func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
    if self.todayH == 0 {
      return 0
    }
    return -120
  }
}
