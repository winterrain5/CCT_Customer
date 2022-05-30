//
//  MyWalletController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/2.
//

import UIKit
import JXPagingView
import JXSegmentedView
class MyWalletController: BaseViewController {
  
  var controllers = [WalletRewardsController(),WalletTransactionsController()]
  lazy var paggingView:JXPagingView = {
    let view = JXPagingView(delegate: self)
    return view
  }()
  
  lazy var headerVc = WalletCardController()
  
  var tableHeaderViewHeight: Int = 264
  var headerInSectionHeight: Int = 40
  
  lazy var titleDataSource: JXSegmentedTitleDataSource = {
    let dataSource = JXSegmentedTitleDataSource()
    dataSource.titles = ["Rewards","Transactions"]
    dataSource.isTitleColorGradientEnabled = true
    dataSource.isTitleZoomEnabled = false
    dataSource.isTitleStrokeWidthEnabled = false
    dataSource.isSelectedAnimable = true
    dataSource.titleSelectedColor = R.color.theamRed()!
    dataSource.titleNormalColor = .black
    dataSource.titleSelectedFont = UIFont(name: .AvenirNextDemiBold, size:14)
    dataSource.titleNormalFont = UIFont(name:.AvenirNextRegular,size:14)
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
  }
  
  private var defautIndex = 0
  convenience init(defautIndex:Int = 0) {
    self.init()
    self.defautIndex = defautIndex
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = "My Wallet"
    
    self.addChild(headerVc)
    
    
    segmentedView.dataSource = titleDataSource
    segmentedView.listContainer = paggingView.listContainerView
    segmentedView.defaultSelectedIndex = defautIndex
    
    let bottomLayer = CALayer()
    bottomLayer.backgroundColor = R.color.line()?.cgColor
    segmentedView.layer.addSublayer(bottomLayer)
    bottomLayer.frame = CGRect(x: 0, y: headerInSectionHeight.cgFloat, width: kScreenWidth, height: 1)
    
    paggingView.mainTableView.gestureDelegate = self
    self.view.addSubview(paggingView)
    paggingView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    
    // 边缘返回处理
    paggingView.listContainerView.scrollView.panGestureRecognizer.require(toFail: self.navigationController!.interactivePopGestureRecognizer!)
    paggingView.mainTableView.panGestureRecognizer.require(toFail: self.navigationController!.interactivePopGestureRecognizer!)
    
  }
  
}

extension MyWalletController:JXPagingMainTableViewGestureDelegate {
  func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
    if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
      return false
    }
    return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
  }
}

extension MyWalletController:JXSegmentedViewDelegate {
  func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
  }
}

extension MyWalletController:JXPagingViewDelegate {
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

extension JXPagingListContainerView: JXSegmentedViewListContainer {}


