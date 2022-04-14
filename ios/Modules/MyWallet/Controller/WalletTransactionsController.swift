//
//  WalletTransactionsController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/2.
//

import UIKit

import JXPagingView
class WalletTransactionsController: BasePagingTableController {
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshData()
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .ClientProfile, path: .getTInvoicesForApp)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "isHistory", value: "1")
    params.set(key: "orderType", value: "0")
    params.set(key: "start", value: page)
    params.set(key: "length", value: kPageSize)
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeByCodable([WalletTranscationModel].self, from: data)  {
        self.dataArray.append(contentsOf: models)
        self.endRefresh(models.count,emptyString: "Your have no Transactions")
      } else {
        self.endRefresh()
      }
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }

  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.register(nibWithCellClass: WalletTransactionCell.self)
    tableView?.rowHeight = 72
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    tableView?.contentInset = .zero
    registRefreshFooter()
  }
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }
  
  override func listViewFrame() -> CGRect {
    return CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 40 - kNavBarHeight)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: WalletTransactionCell.self)
    if dataArray.count > 0 {
      cell.model = dataArray[indexPath.section] as? WalletTranscationModel
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = WalletTransactionSectionView()
    if dataArray.count > 0 {
      view.model = dataArray[section] as? WalletTranscationModel
    }
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 24
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = dataArray[indexPath.section] as! WalletTranscationModel
    let vc = TransactionDetailController(transactionModel: model)
    self.navigationController?.pushViewController(vc)
  }
  
  func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
    return -322 * 0.5
  }
  
}




