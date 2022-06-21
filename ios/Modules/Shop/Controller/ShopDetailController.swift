//
//  ShopDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/13.
//

import UIKit


import JXPagingView
import JXSegmentedView
class ShopDetailController: BaseViewController {
  
  lazy var aboutVc = ShopDetailAboutController()
  lazy var reviewVc = ShopDetailReviewController()
  lazy var controllers = [aboutVc,reviewVc]
  lazy var paggingView:JXPagingView = {
    let view = JXPagingView(delegate: self)
    return view
  }()
  
  var headerView = ShopDetailHeadContainer.loadViewFromNib()
  var bottomView = ShopDetialBottomView()
  var tableHeaderViewHeight: Int = 541
  let headerInSectionHeight: Int = 40
  let bottomSheetHeight:CGFloat = 74 + kBottomsafeAreaMargin
  
  lazy var titleDataSource: JXSegmentedTitleDataSource = {
    let dataSource = JXSegmentedTitleDataSource()
    dataSource.titles = ["About","Review"]
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
    segment.defaultSelectedIndex = 0
    segment.dataSource = titleDataSource
    segment.delegate = self
    segment.indicators = [indicator]
    segment.backgroundColor = .clear
  }
  
  var heartButton = UIButton().then { btn in
    btn.setImage(R.image.shop_nav_heart(), for: .normal)
    btn.size = CGSize(width: 30, height: 44)
  }
  var basketButton = UIButton().then { btn in
    btn.setImage(R.image.shop_nav_basket(), for: .normal)
    btn.badgeType = .Text
    btn.badgeBGColor = R.color.theamRed()
    btn.badgeTextColor = .white
    btn.badgeMinSize = 15
    btn.badgeOriginX = 15
    btn.badgeOriginY = 10
    btn.shouldHideBadgeAtZero = true
    btn.badgeValue = "0"
    btn.size = CGSize(width: 30, height: 44)
  }
  
  private var productId = ""
  private var detailModel = ShopProductDetailModel()
  convenience init(productId:String) {
    self.init()
    self.productId = productId
    aboutVc.productId = productId
    reviewVc.productId = productId
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    segmentedView.dataSource = titleDataSource
    segmentedView.listContainer = paggingView.listContainerView
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
       
    heartButton.addTarget(self, action: #selector(shopHertBarItemAction), for: .touchUpInside)
    let heartItem = UIBarButtonItem(customView: heartButton)
 
    basketButton.addTarget(self, action: #selector(shopBasketBarItemAction), for: .touchUpInside)
    let basketItem = UIBarButtonItem(customView: basketButton)
    self.navigation.item.rightBarButtonItems = [basketItem,heartItem]
    
    
    segmentedView.isHidden = true
    getProductDetail()
    saveRecentViewedProduct()
    
    self.headerView.updateHeightHandler = { [weak self] height in
      guard let `self` = self else { return }
      self.tableHeaderViewHeight = ceil(height.double).int
      self.paggingView.reloadData()
    }
   
    self.view.addSubview(bottomView)
    bottomView.isHidden = true
    bottomView.frame = CGRect(x: 0, y: kScreenHeight - bottomSheetHeight, width: kScreenWidth, height: bottomSheetHeight)
    bottomView.addToCartHandler = { [weak self] in
      self?.addProductToCart()
    }
    bottomView.buyNowHandler = { [weak self] in
      guard let `self` = self else { return }
      guard let product = self.detailModel.Product else{
        return
      }
      let vc = ShopCartController(showType: 1, products: [product])
      self.navigationController?.pushViewController(vc)
    }
    
    
    self.paggingView.mainTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomSheetHeight, right: 0)
  }
  
  @objc func shopHertBarItemAction() {
    let vc = ShopLikeProductController()
    self.navigationController?.pushViewController(vc)
  }
  
  @objc func shopBasketBarItemAction() {
    let vc = ShopCartController()
    self.navigationController?.pushViewController(vc)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getCartCount()
  }
  
  
  func getProductDetail() {
    let params = SOAPParams(action: .Product, path: .getProductsDetails)
    params.set(key: "id", value: productId)
    params.set(key: "reviewLimit", value: 2)
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(ShopProductDetailModel.self, from: data) {
        self.detailModel = model
        self.headerView.product = self.detailModel.Product
        self.aboutVc.headView.model = self.detailModel
        self.reviewVc.headView.model = self.detailModel
      }else {
        Toast.showError(withStatus: "Decode ShopProductDetailModel Failed")
      }
      self.bottomView.isHidden = false
      self.segmentedView.isHidden = false
    } errorHandler: { e in
      
    }

  }
  
  func getCartCount() {
    let params = SOAPParams(action: .Cart, path: .getCartCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      self.basketButton.badgeValue = String(data: data, encoding: .utf8) ?? "0"
    } errorHandler: { e in
      
    }

  }
  
  func saveRecentViewedProduct() {
    let params = SOAPParams(action: .Product, path: .saveRecentViewedProduct)
    params.set(key: "productId", value: productId)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      self.getCartCount()
    } errorHandler: { e in
      
    }

  }
  
  func addProductToCart() {
    let params = SOAPParams(action: .Cart, path: .saveClientCart)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "0")
    params.set(key: "goodsId", value: self.detailModel.Product?.id ?? "")
    params.set(key: "goodsNum", value: self.detailModel.Product?.count ?? "1")
    NetworkManager().request(params: params) { data in
      Toast.showSuccess(withStatus: "Added successfully")
      self.getCartCount()
    } errorHandler: { e in
      
    }
  }
  
}

extension ShopDetailController:JXPagingMainTableViewGestureDelegate {
  func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
    if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
      return false
    }
    return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
  }
}

extension ShopDetailController:JXSegmentedViewDelegate {
  func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
  }
}

extension ShopDetailController:JXPagingViewDelegate {
  func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
    return tableHeaderViewHeight
  }
  
  func tableHeaderView(in pagingView: JXPagingView) -> UIView {
    return headerView
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



