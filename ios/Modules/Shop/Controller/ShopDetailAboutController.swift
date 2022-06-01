//
//  ShopDetailAboutController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/13.
//

import UIKit

class ShopDetailAboutController: BasePagingTableController {
  let headView = ShopDetailAboutHeadView.loadViewFromNib()
  var productId = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshData()
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .Product, path: .getRecommendProducts)
    params.set(key: "productId", value: productId)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "limit", value: 5)
    params.set(key: "isOnline", value: 1)
    
    NetworkManager().request(params: params) { data in
      if let data = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
        self.dataArray = data
      }
      self.endRefresh(self.dataArray.count)
    } errorHandler: { e in
      
    }

  }
  
  override func createListView() {
    super.createListView()
    self.tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: 200)
    headView.updateHeightHandler = { [weak self] height in
      guard let `self` = self else { return }
      self.headView.height = height
      self.tableView?.tableHeaderView = self.headView
    }
    
    self.tableView?.register(cellWithClass: ShopCollectionCell.self)
  }
  
  override func listViewFrame() -> CGRect {
    return CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 40 - kNavBarHeight)
  }

  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 296
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ShopCollectionCell.self)
    cell.dataType = .Other
    
    if self.dataArray.count > 0 {
      cell.datas = self.dataArray as! [ShopProductModel]
    }
    
    cell.selectionStyle = .none
    return cell
  }
  
  
}
