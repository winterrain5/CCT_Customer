//
//  WalletRewardsController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/2.
//

import UIKit
import JXPagingView
import PromiseKit
class WalletRewardsController: BasePagingTableController {

  var coupons:[WalletCouponsModel] = []
  var vouchers:[WalletVouchersModel] = []
  
  override func viewDidLoad() {
      super.viewDidLoad()

    getClienGifts()
    getClientValidRewards()
  }

  /// coupons
  func getClientValidRewards() {
    let params = SOAPParams(action: .RewardDiscounts, path: .getClientValidRewards)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "isDiscount", value: "1")
    params.set(key: "exceed", value: "0")
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(WalletCouponsModel.self, from: data) {
        self.coupons = models
        self.tableView?.reloadData()
      }
    } errorHandler: { e in
      
    }
  }
  
  /// voucher
  func getClienGifts() {
    let params = SOAPParams(action: .GiftCertificate, path: .getClientGifts)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "isValid", value: "1")
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(WalletVouchersModel.self, from: data) {
        self.vouchers = models
        self.tableView?.reloadData()
      }
    } errorHandler: { e in
      
    }
  }


  override func listViewFrame() -> CGRect {
    return CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 40 - kNavBarHeight)
  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.register(nibWithCellClass: WalletVouchersCell.self)
    tableView?.register(nibWithCellClass: WalletCouponsCell.self)
    
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 256
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withClass: WalletVouchersCell.self)
      cell.vouchers = vouchers
      cell.selectionStyle = .none
      return cell
    }else {
      let cell = tableView.dequeueReusableCell(withClass: WalletCouponsCell.self)
      cell.coupons = coupons
      cell.selectionStyle = .none
      return cell
    }
    
  }
}



