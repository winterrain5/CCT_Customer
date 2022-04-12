//
//  BaseCollectionController.swift
//  OneOnline
//
//  Created by Derrick on 2020/2/28.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit

class BaseCollectionController: BaseViewController,DataLoadable {
  
  var dataArray: [Any] = []
  
  var refreshWhenLoad: Bool = false
  
  var isFirstLoad: Bool = true
  
  var page: Int = 1
  
  var pageSize: Int = 18
  
  var shouldDisplayEmptyDataView: Bool = false
  var emptyDataType: EmptyDataType = .NoData
  var emptyNoDataString: String = ""
  var emptyNoDataImage: String = ""
  
  public var collectionView:UICollectionView?
  public var cellIdentifier:String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createListView()
  }
  
  func createListView() {
    collectionView = UICollectionView.init(frame: listViewFrame(), collectionViewLayout: listViewLayout())
    collectionView?.backgroundColor = UIColor.clear
    collectionView?.showsHorizontalScrollIndicator = false
    collectionView?.showsVerticalScrollIndicator = false
    collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
    
    collectionView?.dataSource = self
    collectionView?.delegate = self
    
    collectionView?.emptyDataSetSource = self
    collectionView?.emptyDataSetDelegate = self
  
    view.addSubview(collectionView!)
    
    if #available(iOS 11.0, *) {
      collectionView?.contentInsetAdjustmentBehavior = .never
    } else {
      // Fallback on earlier versions
    }
    
  }
  
  func listViewFrame() -> CGRect {
    return CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
  }
  
  func listViewLayout() -> UICollectionViewLayout {
    return UICollectionViewFlowLayout()
  }
  
  func registRefreshHeader(colorStyle:RefreshColorStyle = .gray) {
    let header = RefreshAnimationHeader{ [weak self] in
      self?.loadNewData()
    }
    header.colorStyle = colorStyle
    collectionView?.mj_header = header
    if refreshWhenLoad {
      collectionView?.mj_header?.beginRefreshing()
    }
  }
  
  func registRefreshFooter() {
    let footer = RefreshAnimationFooter{ [weak self] in
      self?.loadNextPage()
    }
    collectionView?.mj_footer = footer
    collectionView?.mj_footer?.isHidden = true
  }
  
  func reloadData() {
    self.collectionView?.reloadData()
    if isFirstLoad {
      collectionView?.reloadEmptyDataSet()
    }
    isFirstLoad = false
    
  }

  
  func loadNewData() {
    page=1
    if self.dataArray.count > 0 {
      self.dataArray.removeAll()
    }
    refreshData()
  }
  
  func refreshData() {
    fatalError("子类重写该方法，这里加入网络请求")
  }
  
  func loadNextPage() {
    page+=1
    refreshData()
  }
  
  func endRefresh(_ type: EmptyDataType, emptyString: String = EmptyStatus.Message.NoData.rawValue) {
    shouldDisplayEmptyDataView = type == .Success ? false : true
    self.emptyDataType = type
    self.emptyNoDataString = emptyString
    reloadData()
    endHeaderFooterRefresh(0)
  }
  
  func endRefresh(_ count: Int,
                  emptyString: String = EmptyStatus.Message.NoData.rawValue,
                  emptyImage:String = EmptyStatus.Image.NoData.rawValue) {
    shouldDisplayEmptyDataView = self.dataArray.count > 0 ? false : true
    self.emptyDataType = self.dataArray.count > 0 ? .Success : .NoData
    self.emptyNoDataImage = emptyImage
    self.emptyNoDataString = emptyString
    reloadData()
    endHeaderFooterRefresh(count)
  }
  
  func endRefresh(_ count: Int,
                  emptyString: String = EmptyStatus.Message.NoData.rawValue) {
    shouldDisplayEmptyDataView = self.dataArray.count > 0 ? false : true
    self.emptyDataType = self.dataArray.count > 0 ? .Success : .NoData
    self.emptyNoDataString = emptyString
    reloadData()
    endHeaderFooterRefresh(count)
  }
  
  func endRefresh() {
    shouldDisplayEmptyDataView = false
    reloadData()
    endHeaderFooterRefresh(0)
  }
  
  func endHeaderFooterRefresh(_ count: Int) {
    endHeaderRefresh()
    endFooterRefresh(count)
  }
  
  func endHeaderRefresh() {
    guard let header = collectionView?.mj_header else {
      return
    }
    if header.isRefreshing {
      collectionView?.mj_header?.endRefreshing()
    }
  }
  
  func endFooterRefresh(_ count:Int) {
    guard let footer = collectionView?.mj_footer else {
      return
    }
    if footer.isRefreshing {
      collectionView?.mj_footer?.endRefreshing()
    }
    
    let isNoMoreData = count < pageSize || count == 0
    collectionView?.mj_footer?.isHidden = isNoMoreData
  }
  
  
}


extension  BaseCollectionController : UICollectionViewDataSource,UICollectionViewDelegate {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
  
}

extension  BaseCollectionController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
    return EmptyDataType.emptyImage(for: self.emptyDataType,noDataImage: self.emptyNoDataImage)
  }
  
  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return EmptyDataType.emptyString(for: self.emptyDataType, noDataString:self.emptyNoDataString)
  }
  
  func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
    return 24
  }
  
  func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
    return shouldDisplayEmptyDataView
  }
  
  func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
    return true
  }
  
}


