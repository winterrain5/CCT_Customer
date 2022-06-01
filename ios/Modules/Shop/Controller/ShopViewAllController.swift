//
//  ShopViewAllController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit

class ShopViewAllController: BaseTableController {
  private var headerView = ShopSearchView()
  private var dataType:ShopDataType = .NewProducts
  convenience init(dataType:ShopDataType) {
    self.init()
    self.dataType = dataType
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if dataType == .NewProducts {
      self.navigation.item.title = "New Products"
    }else {
      self.navigation.item.title = "Recently Viewed"
    }
    
    refreshData()
  }
  
  override func refreshData() {
    showSkeleton()
    if dataType == .NewProducts {
      getNewFeaturedProducts()
    }else {
      getRecentViewedProducts()
    }
  }
  
  func getNewFeaturedProducts()  {
    let params = SOAPParams(action: .Product, path: .getNewFeaturedProducts)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "isFeatured", value: 0)
    params.set(key: "isNew", value: 1)
    params.set(key: "isOnline", value: 1)
    params.set(key: "limit", value: 1000)
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
        self.dataArray = models
      }
      self.endRefresh(self.dataArray.count,emptyString: "No Datas")
      self.hideSkeleton()
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
      self.hideSkeleton()
    }
  }
  
  func getRecentViewedProducts() {
    let params = SOAPParams(action: .Product, path: .getRecentViewedProduct)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "isOnline", value: 1)
    params.set(key: "limit", value: 1000)
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
        self.dataArray = models
      }
      self.endRefresh(self.dataArray.count,emptyString: "No Datas")
      self.hideSkeleton()
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
      self.hideSkeleton()
    }
  }
  
 
  
  override func createListView() {
    super.createListView()
    
    tableView?.register(nibWithCellClass: ShopLikeProductCell.self)
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    self.view.isSkeletonable = true
    self.tableView?.isSkeletonable = true
    self.cellIdentifier = ShopLikeProductCell.className
    
    self.tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: 104)
    headerView.searchDidEndHandler = { [weak self] text in
      let result = self?.dataArray.filter({ e -> Bool in
        let model = e as! ShopProductModel
        return model.alias.lowercased().contains(text.lowercased()) || model.name.lowercased().contains(text.lowercased())}
      )
      self?.dataArray = result ?? []
      self?.endRefresh(self?.dataArray.count ?? 0,emptyString: "No Products Found")
    }
//
    self.registRefreshHeader()
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 152
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ShopLikeProductCell.self)
    if self.dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? ShopProductModel
      cell.updateCellIsLikeStatus = { model in
        let row = self.dataArray.firstIndex(where: { ($0 as! ShopProductModel).id == model.id }) ?? 0
        let index = IndexPath(row: row, section: 0)
        self.tableView?.reloadRows(at: [index], with: .automatic)
      }
    }
    return cell
  }

}
