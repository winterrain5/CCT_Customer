//
//  ShopViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit
import PromiseKit
class ShopViewController: BaseTableController {
  var headerView = ShopHeaderView.loadViewFromNib()
  var recentlyProducts:[ShopProductModel] = []
  var newProducts:[ShopProductModel] = []
  var bannerProducts:[ShopProductModel] = []
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
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = "Shop"
    
    heartButton.addTarget(self, action: #selector(shopHertBarItemAction), for: .touchUpInside)
    let heartItem = UIBarButtonItem(customView: heartButton)
 
    basketButton.addTarget(self, action: #selector(shopBasketBarItemAction), for: .touchUpInside)
    let basketItem = UIBarButtonItem(customView: basketButton)
    self.navigation.item.rightBarButtonItems = [basketItem,heartItem]
    
    
  }
  
  @objc func shopHertBarItemAction() {
    let vc = ShopLikeProductController()
    self.navigationController?.pushViewController(vc)
  }
  
  @objc func shopBasketBarItemAction() {
    let vc = ShopCartController(showType: 0)
    self.navigationController?.pushViewController(vc)
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshData()
  }
  
 
  override func refreshData() {
    when(fulfilled: getNewFeaturedProducts(),getRecentViewedProducts(),getBannerProducts()).done { _ in
      self.headerView.datas = self.bannerProducts
      self.endRefresh()
      
    }.catch { e in
      Toast.showError(withStatus: e.asAPIError.errorInfo().message)
    }
    getCartCount()
  }
  
  func getNewFeaturedProducts() -> Promise<Void> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Product, path: .getNewFeaturedProducts)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "isFeatured", value: 0)
      params.set(key: "isNew", value: 1)
      params.set(key: "isOnline", value: 1)
      params.set(key: "limit", value: 4)
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
          self.newProducts = models
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode ShopProductModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
    }
  }
  
  func getRecentViewedProducts() -> Promise<Void> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Product, path: .getRecentViewedProduct)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "isOnline", value: 1)
      params.set(key: "limit", value: 4)
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
          self.recentlyProducts = models
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode ShopProductModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
    }
  }
  
  func getBannerProducts() -> Promise<Void> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Product, path: .getNewFeaturedProducts)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "isFeatured", value: 1)
      params.set(key: "isNew", value: "false")
      params.set(key: "isOnline", value: 1)
      params.set(key: "limit", value: 4)
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
          self.bannerProducts = models
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode ShopProductModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }

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
  
  override func createListView() {
    super.createListView()
    
    self.tableView?.register(cellWithClass: ShopCollectionCell.self)
    
    self.tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: 425)
    
    self.registRefreshHeader()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 296
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withClass: ShopCollectionCell.self)
      cell.dataType = .RecentlyViewed
      cell.datas = recentlyProducts
      cell.selectionStyle = .none
      return cell
    }
    if indexPath.row == 1 {
      let cell = tableView.dequeueReusableCell(withClass: ShopCollectionCell.self)
      cell.dataType = .NewProducts
      cell.datas = newProducts
      cell.selectionStyle = .none
      return cell
    }
    
    return UITableViewCell()
  }
  
}
