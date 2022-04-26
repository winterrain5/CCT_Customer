//
//  CardUserDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/9.
//

import UIKit

class CardUserDetailController: BaseTableController {
  
  var headView = CardUserDetailHeadView.loadViewFromNib()
  var cardUserModel:CardOwnerModel?
  convenience init(cardUserModel:CardOwnerModel?) {
    self.init()
    self.cardUserModel = cardUserModel
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "User Details"
    self.headView.cardUserModel = cardUserModel
    refreshData()
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .SalesReport, path: .getFriendUsedCard)
    params.set(key: "friendId", value: cardUserModel?.friend_id ?? "")
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeByCodable([FriendUseCardModel].self, from: data) {
        self.dataArray = models
      }
      self.endRefresh(self.dataArray.count, emptyString: "No Transactions")
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }

  }
  override func createListView() {
    super.createListView()
    
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: 260)
    tableView?.register(nibWithCellClass: WalletTransactionCell.self)
    
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    registRefreshFooter()
  }
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }
  
  override func listViewFrame() -> CGRect {
    return CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.dataArray.count > 0 {
      let model = self.dataArray[section] as? FriendUseCardModel
      return model?.transActions?.count ?? 0
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: WalletTransactionCell.self)
    if dataArray.count > 0 {
      if let transcations = (self.dataArray[indexPath.section] as? FriendUseCardModel)?.transActions, transcations.count > 0 {
        cell.transcation = transcations[indexPath.row]
      }
      
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = WalletTransactionSectionView()
    if dataArray.count > 0 {
      view.transcation = self.dataArray[section] as? FriendUseCardModel
    }
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 24
  }
  
  
  func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
    return -260 * 0.5
  }
  
  
  
  
}
