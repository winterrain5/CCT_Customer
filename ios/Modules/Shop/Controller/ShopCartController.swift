//
//  ShopCartController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit

class ShopCartController: BaseTableController {

  override func viewDidLoad() {
    super.viewDidLoad()
    navigation.item.title = "Your Cart"
    refreshData()
  }
  
  override func refreshData() {
    
  }

  override func createListView() {
    super.createListView()
    
    tableView?.register(nibWithCellClass: ShopCartCell.self)
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    self.view.isSkeletonable = true
    self.tableView?.isSkeletonable = true
    self.cellIdentifier = ShopCartCell.className
    
//
    self.registRefreshHeader()
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 152
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ShopCartCell.self)
    if self.dataArray.count > 0 {
      
    }
    return cell
  }


}
