//
//  ShopCheckOutController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/15.
//

import UIKit

class ShopCheckOutController: BaseTableController {
  var footerView = ShopCheckOutFooterView.loadViewFromNib()
  private var orderId = ""
  convenience init(orderId:String, products:[Product] = []) {
    self.init()
    self.dataArray = products
    self.orderId = orderId
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = "Check Out"
  }
  
  override func createListView() {
    super.createListView()
    tableView?.register(nibWithCellClass: ProductItemCell.self)
    tableView?.separatorStyle = .singleLine
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView?.separatorColor = UIColor(hexString: "#E0E0E0")
    
    tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 911)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 92
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ProductItemCell.self)
    if self.dataArray.count > 0{
      cell.product = self.dataArray[indexPath.row] as? Product
    }
    return cell
  }
}
