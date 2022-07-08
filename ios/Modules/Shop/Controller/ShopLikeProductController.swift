//
//  ShopLikeItemController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit

class ShopLikeProductController: BaseTableController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigation.item.title = "Like Items"
    refreshData()
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .Product, path: .getLikeProduct)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    showSkeleton()
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
        models.forEach({ $0.isLike = true })
        self.dataArray = models
      }
      
      self.endRefresh(self.dataArray.count,emptyString: "No Like Items")
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
    
    registRefreshHeader()
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
        self.dataArray.removeFirst(where: { ($0 as! ShopProductModel).id == model.id })
        self.reloadData()
      }
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let productId = (self.dataArray as! [ShopProductModel])[indexPath.row].id
    let vc = ShopDetailController(productId: productId)
    self.navigationController?.pushViewController(vc, completion: nil)
  }
}
