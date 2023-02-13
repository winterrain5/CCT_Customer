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
    params.set(key: "start", value: page)
    params.set(key: "length", value: pageSize)
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decodeArrayByHandJSON(WalletTranscationModel.self, from: data) else {
        self.endRefresh()
        return
      }
      self.dataArray.append(contentsOf: models)
      self.endRefresh(models.count, emptyString: "No Transactions")
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }

  }
  override func createListView() {
    super.createListView()
    
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth, height: 255)
    tableView?.register(nibWithCellClass: WalletTransactionCell.self)
    
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    registRefreshHeader(colorStyle: .gray)
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
    return 1
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 24
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: WalletTransactionCell.self)
    if dataArray.count > 0 {
      if let model = (self.dataArray[indexPath.section] as? WalletTranscationModel) {
        cell.model = model
      }
      
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = WalletTransactionSectionView()
    if dataArray.count > 0 {
      view.model = self.dataArray[section] as? WalletTranscationModel
    }
    return view
  }
  

  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = dataArray[indexPath.section] as! WalletTranscationModel
    let vc = TransactionDetailController(transactionModel: model)
    self.navigationController?.pushViewController(vc)
  }
  
  
  func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
    return 255 * 0.5
  }
  
  
  
  
}
