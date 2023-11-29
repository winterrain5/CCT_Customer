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
  var packages:[WalletPackagesModel] = []
  override func viewDidLoad() {
      super.viewDidLoad()

    getClienGifts()
    getClientValidRewards()
    getClientPackages()
    
  }

  /// coupons
  func getClientValidRewards() {
    let params = SOAPParams(action: .RewardDiscounts, path: .getClientValidRewards)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "isDiscount", value: "1")
    params.set(key: "exceed", value: "0")
    NetworkManager().request(params: params) { data in
      guard let json = try? JSON.init(data: data) else { return }
      
      if let models = DecodeManager.decodeArrayByHandJSON(WalletCouponsModel.self, from: data) {
        models.enumerated().forEach { index,item in
          item.desc = json[index]["description"].string
        }
        self.coupons = models
        self.tableView?.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
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
      guard let json = try? JSON.init(data: data) else { return }
      if let models = DecodeManager.decodeArrayByHandJSON(WalletVouchersModel.self, from: data) {
        models.enumerated().forEach { index,item in
          item.desc = json[index]["description"].string
        }
        self.vouchers = models
        self.tableView?.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
      }
    } errorHandler: { e in
      
    }
  }
  
  func getClientPackages() {
    let params = SOAPParams(action: .Voucher, path: .getPackagesByClientId)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(WalletPackagesModel.self, from: data) {
        self.packages = models
        self.tableView?.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
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
    tableView?.register(nibWithCellClass: WalletPackagesCell.self)
    
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 256
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withClass: WalletVouchersCell.self)
      cell.vouchers = vouchers
      cell.selectionStyle = .none
      return cell
    }else if indexPath.row == 1{
      let cell = tableView.dequeueReusableCell(withClass: WalletCouponsCell.self)
      cell.coupons = coupons
      cell.selectionStyle = .none
      return cell
    }else {
      let cell = tableView.dequeueReusableCell(withClass: WalletPackagesCell.self)
      cell.packages = packages
      cell.selectionStyle = .none
      return cell
    }
    
  }
}



