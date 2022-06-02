//
//  BookingViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/29.
//

import UIKit
import SideMenuSwift
import JXPagingView
import JXSegmentedView

class BookingViewController: BaseViewController {
  
  var controllers = [BookingUpcomingController(),BookingCompletedController()]
  lazy var paggingView:JXPagingView = {
    let view = JXPagingView(delegate: self)
    return view
  }()
  
  lazy var headerVc = BookingHeadController()
  
  var tableHeaderViewHeight: Int = 0
  var headerInSectionHeight: Int = 40
  
  lazy var titleDataSource: JXSegmentedTitleDataSource = {
    let dataSource = JXSegmentedTitleDataSource()
    dataSource.titles = ["Upcoming","Completed"]
    dataSource.isTitleColorGradientEnabled = true
    dataSource.isTitleZoomEnabled = false
    dataSource.isTitleStrokeWidthEnabled = false
    dataSource.isSelectedAnimable = true
    dataSource.titleSelectedColor = R.color.theamRed()!
    dataSource.titleNormalColor = .black
    dataSource.titleSelectedFont = UIFont(name:.AvenirNextDemiBold,size: 14)
    dataSource.titleNormalFont = UIFont(name: .AvenirNextRegular,size: 14)
    dataSource.isItemSpacingAverageEnabled = true
    return dataSource
  }()
  
  private lazy var indicator:JXSegmentedIndicatorLineView = {
    let indicator = JXSegmentedIndicatorLineView()
    indicator.indicatorWidth = 80
    indicator.indicatorHeight = 2
    indicator.indicatorColor = R.color.theamRed()!
    indicator.verticalOffset = 0
    indicator.lineStyle = .lengthen
    return indicator
  }()
  
  
  lazy var segmentedView = JXSegmentedView().then { (segment) in
    segment.dataSource = titleDataSource
    segment.delegate = self
    segment.indicators = [indicator]
    segment.backgroundColor = .clear
    segment.defaultSelectedIndex = 0
  }
  
  
  init() {
    super.init(nibName: nil, bundle: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(menuDidClick(_:)), name: .menuDidOpenVc, object: nil)
    NotificationCenter.default.addObserver(forName:.bookingDataChanged, object: nil, queue: .main) { _ in
      self.getClientBookedService()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: nil, backButtonTitle: nil)
    self.navigation.item.leftBarButtonItem = UIBarButtonItem(image: R.image.notification_menu(), style: .plain, target: self, action: #selector(leftItemAction))
    self.navigation.item.rightBarButtonItem = UIBarButtonItem(image: R.image.booking_add(), style: .plain, target: self, action: #selector(rightItemAction))
    self.navigation.item.title = "Appointment"
    self.addChild(headerVc)
    
    
    segmentedView.dataSource = titleDataSource
    segmentedView.listContainer = paggingView.listContainerView
   
    
    let bottomLayer = CALayer()
    bottomLayer.backgroundColor = R.color.line()?.cgColor
    segmentedView.layer.addSublayer(bottomLayer)
    bottomLayer.frame = CGRect(x: 0, y: headerInSectionHeight.cgFloat, width: kScreenWidth, height: 1)
    
    paggingView.mainTableView.gestureDelegate = self
    self.view.addSubview(paggingView)
    paggingView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    
    getClientBookedService()
  }

  
  func getClientBookedService() {
    let params = SOAPParams(action: .BookingOrder, path: .getClientBookedServices)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "date", value: Date().string(withFormat: "yyyy-MM-dd"))
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingTodayModel.self, from: data) {
        if models.count > 0 {
          let additionalH = models.filter({ $0.staff_is_random == "2" }).count > 0 ? 28 : 0
          if models.count > 1 {
            self.tableHeaderViewHeight = 317 + additionalH
          }else {
            self.tableHeaderViewHeight = 297 + additionalH
          }
        }else {
          self.tableHeaderViewHeight = 0
        }
        
        self.headerVc.models = models
      }else {
        self.tableHeaderViewHeight = 0
      }
      NotificationCenter.default.post(name: NSNotification.Name.bookingTodayLoaded, object: self.tableHeaderViewHeight)
      self.paggingView.reloadData()
    } errorHandler: { e in
      self.tableHeaderViewHeight = 0
      NotificationCenter.default.post(name: NSNotification.Name.bookingTodayLoaded, object: self.tableHeaderViewHeight)
    }

  }
  
  @objc func menuDidClick(_ noti:Notification) {
    let selStr = noti.object as! String
    let sel = NSSelectorFromString(selStr)
    if self.responds(to: sel) {
      self.perform(sel)
    }
  }
  
  @objc func leftItemAction() {
    sideMenuController?.revealMenu()
  }
  
  @objc func rightItemAction() {
    
    
    getClientCancelCount()
    
  }
  
  func getClientCancelCount() {
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

extension BookingViewController:JXPagingMainTableViewGestureDelegate {
  func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
    if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
      return false
    }
    return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
  }
}

extension BookingViewController:JXSegmentedViewDelegate {
  func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
  }
}

extension BookingViewController:JXPagingViewDelegate {
  func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
    return tableHeaderViewHeight
  }
  
  func tableHeaderView(in pagingView: JXPagingView) -> UIView {
    return headerVc.view
  }
  
  func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
    return headerInSectionHeight
  }
  
  func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
    segmentedView.width = kScreenWidth
    return segmentedView
  }
  
  func numberOfLists(in pagingView: JXPagingView) -> Int {
    return titleDataSource.dataSource.count
  }
  
  func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
    return controllers[index]
  }
  
  
}
