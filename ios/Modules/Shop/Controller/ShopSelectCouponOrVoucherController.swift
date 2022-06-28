//
//  ShopSelectCouponOrVoucherController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/15.
//

import UIKit

class ShopSelectCouponOrVoucherController: BaseTableController {
  var selectCouponHandler:((WalletCouponsModel?)->())?
  var selectVoucherHandler:((WalletVouchersModel?)->())?
  private var selectCoupon:WalletCouponsModel?
  private var selectVoucher:WalletVouchersModel?
  /// 0 Coupon 1 voucher
  private var selectType:Int = 0
  convenience init(selectType:Int,selectCoupon:WalletCouponsModel? = nil,selectVoucher:WalletVouchersModel? = nil) {
    self.init()
    self.selectType = selectType
    self.selectCoupon = selectCoupon
    self.selectVoucher = selectVoucher
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = selectType == 0 ? "Coupon" : "Voucher"
    refreshData()
  }
  
  override func refreshData() {
    if selectType == 0 {
      getClientValidRewards()
    }else {
      getClienGifts()
    }
  }
  /// coupons
  func getClientValidRewards() {
    let params = SOAPParams(action: .RewardDiscounts, path: .getClientValidRewards)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "isDiscount", value: "1")
    params.set(key: "exceed", value: "0")
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(WalletCouponsModel.self, from: data) {
        models.forEach({
          if $0.id == self.selectCoupon?.id {
            $0.isSelected = true
          }
        })
        self.dataArray = models
        self.endRefresh(models.count,emptyString: "No Coupons")
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
        models.forEach({
          if $0.id == self.selectVoucher?.id {
            $0.isSelected = true
          }
        })
        self.dataArray = models
        self.endRefresh(models.count,emptyString: "No Vouchers")
      }
    } errorHandler: { e in
      
    }
  }

  
  override func createListView() {
    super.createListView()
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = .zero
    
    tableView?.register(nibWithCellClass: ShopSelectCouponOrVoucherCell.self)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 236
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ShopSelectCouponOrVoucherCell.self)
    if self.dataArray.count > 0 {
      if selectType == 0 {
        cell.coupon = self.dataArray[indexPath.row] as? WalletCouponsModel
      }else {
        cell.voucher = self.dataArray[indexPath.row] as? WalletVouchersModel
      }
      cell.useNowHandler = { [weak self] model in
        guard let `self` = self else { return }
        if self.selectType == 0 {
          let temp = model as! WalletCouponsModel
          self.selectCouponHandler?(temp.isSelected ? temp : nil)
        }else {
          let temp = model as! WalletVouchersModel
          self.selectVoucherHandler?(temp.isSelected ? temp : nil)
        }
        self.reloadData()
      }
    }
    cell.selectionStyle = .none
    return cell
  }
}
