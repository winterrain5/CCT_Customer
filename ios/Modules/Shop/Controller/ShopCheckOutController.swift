//
//  ShopCheckOutController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/15.
//

import UIKit

let bottomSheetHeight:CGFloat = 74 + kBottomsafeAreaMargin
class ShopCheckOutController: BaseTableController {
  lazy var footerView = ShopCheckOutFooterView.loadViewFromNib()
  
  convenience init(orderId:String, products:[ShopCartModel] = []) {
    self.init()
    self.dataArray = products
    
    footerView.orderId = orderId
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = "Check Out"
    
    addLeftBarButtonItem()
    leftButtonDidClick = { [weak self] in
      guard let `self` = self else { return }
      self.navigationController?.viewControllers.forEach({ vc in
        if vc is ShopViewController {
          self.navigationController?.popToViewController(vc, animated: true)
        }
      })
    }
    
    interactivePopGestureRecognizerEnable = false
  }
  
  override func createListView() {
    super.createListView()
    tableView?.register(nibWithCellClass: ProductItemCell.self)
    tableView?.separatorStyle = .singleLine
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView?.separatorColor = UIColor(hexString: "#E0E0E0")
    
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomSheetHeight, right: 0)
    
    tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 911)
    footerView.updateContentHeight = { [weak self] height in
      guard let `self` = self else { return }
      self.footerView.height = height
      self.tableView?.tableFooterView = self.footerView
    }
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    footerView.removeFooterView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    footerView.addFooterView()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ProductItemCell.self)
    if self.dataArray.count > 0{
      cell.cart = self.dataArray[indexPath.row] as? ShopCartModel
    }
    return cell
  }
  
 
}
