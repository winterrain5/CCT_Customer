//
//  ShopCartController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit
import PromiseKit
import SwipeCellKit
import Haptica
class ShopCartController: BaseTableController {
  lazy var bottomSheetHeight:CGFloat = 74 + kBottomsafeAreaMargin
  lazy var checkoutBtn = LoadingButton().then { btn in
    btn.backgroundColor = R.color.theamRed()
    btn.cornerRadius = 22
    btn.titleForNormal = "Check Out"
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.addTarget(self, action: #selector(checkoutAction), for: .touchUpInside)
  }
  lazy var bottomView = UIView().then { view in
    view.backgroundColor = .clear
    view.addSubview(checkoutBtn)
    checkoutBtn.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.height.equalTo(44)
      make.top.equalToSuperview().offset(16)
    }
    
  }
  var footerView = ShopCartFooterView.loadViewFromNib()
  
  private var showType = 0
  private var taxModel:TaxesModel!
  private var staffModel:BusinessManModel?
  let dateHMS = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
  let dateYMD = Date().string(withFormat: "yyyy-MM-dd")
  
  /// init
  /// - Parameters:
  ///   - showType: 0 cart 1 buynow
  ///   - products: buy now 带过来的数据
  convenience init(showType:Int,products:[Product] = []) {
    self.init()
    self.showType = showType
    self.dataArray = products.map({
      let cart = ShopCartModel()
      cart.goods_num = $0.count
      cart.picture = $0.picture
      cart.alias = $0.alias
      cart.name = $0.name
      cart.sell_price = $0.sell_price
      cart.goods_id = $0.id
      return cart
    })
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigation.item.title = showType == 0 ? "Your Cart" : "Buy Now"
   
    refreshData()
  }
  
  override func refreshData() {
    if showType == 1 {
      if self.dataArray.count > 0 {
        addTableFooterView()
      }
      updateFooterViewData()
      reloadData()
      endRefresh(dataArray.count, emptyString: "No Items")
      return
    }
    let params = SOAPParams(action: .Cart, path: .getTCart)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ShopCartModel.self, from: data) {
        self.dataArray = models
        self.endRefresh(models.count,emptyString: "No Items")
        self.updateFooterViewData()
        if self.dataArray.count > 0 {
          self.addTableFooterView()
        }else {
          self.removerTableFooterView()
        }
      }
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
    }

  }
  
  @discardableResult
  func updateFooterViewData() -> Float{
    if self.dataArray.count == 0 { return 0 }
    let products = self.dataArray as! [ShopCartModel]
    let count = products.reduce(0, { $0 + $1.goods_num })
    let price = products.reduce(0, { $0 + ($1.goods_num.float * ($1.sell_price.float() ?? 0)) })
    let formatPrice = price.string.formatMoney().dolar
    footerView.update(count: count, subTotal: formatPrice, total: formatPrice)
    return price
  }

  override func createListView() {
    super.createListView()
    
    tableView?.register(nibWithCellClass: ShopCartCell.self)
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomSheetHeight, right: 0)
    
    self.view.isSkeletonable = true
    self.tableView?.isSkeletonable = true
    self.cellIdentifier = ShopCartCell.className
    
    
    
    self.registRefreshHeader()
  }
  
  func addTableFooterView() {
    tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 138)
    
    self.view.addSubview(bottomView)
    bottomView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(bottomSheetHeight)
      
    }
  }
  
  func removerTableFooterView() {
    tableView?.tableFooterView = nil
    bottomView.removeFromSuperview()
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 152
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ShopCartCell.self)
    if self.dataArray.count > 0 {
      cell.cart = self.dataArray[indexPath.row] as? ShopCartModel
      cell.updateProductCountHandler = { [weak self] model in
        if model.goods_num == 0 {
          AlertView.show(title: "", message: "Are you sure you want to remove this item?", leftButtonTitle: "No", rightButtonTitle: "Yes", messageAlignment: .center) {
            model.goods_num = 1
            self?.tableView?.reloadRows(at: [IndexPath(row: (self?.dataArray as! [ShopCartModel]).firstIndex(of: model) ?? 0, section: 0)], with: .none)
          } rightHandler: {
            self?.deleteProduct(model)
          } dismissHandler: {
                
          }
          return
        }
        self?.updateGoodCount(model)
      }
      
      cell.delegate = self
    }
    return cell
  }

  func updateGoodCount(_ model:ShopCartModel) {
    let params = SOAPParams(action: .Cart, path: .saveClientCart)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "0")
    params.set(key: "goodsId", value: model.goods_id)
    params.set(key: "goodsNum", value: model.goods_num)
    NetworkManager().request(params: params) { data in
      self.updateFooterViewData()
    } errorHandler: { e in
      
    }
  }
  
  func deleteProduct(_ model:ShopCartModel) {
    let params = SOAPParams(action: .Cart, path: .delClientCart)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "goodsId", value: model.goods_id)
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      self.loadNewData()
    } errorHandler: { e in
      Toast.dismiss()
    }
  }

  @objc func checkoutAction() {
    checkoutBtn.startAnimation()
    firstly{
      getAllTaxes()
    }.then {
      self.getBusiness()
    }.then {
      self.checkoutTOrder()
    }.done {
      self.checkoutBtn.stopAnimation()
    }.catch { e in
      self.checkoutBtn.stopAnimation()
      Toast.showError(withStatus: e.asAPIError.errorInfo().message)
    }
  }
  
  func getAllTaxes() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Tax, path: .getTAllTaxes,isNeedToast: false)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeByCodable([TaxesModel].self, from: data) {
          self.taxModel = models.first
        }else {
          let taxModel = TaxesModel()
          taxModel.id = "0"
          taxModel.rate = "7"
          taxModel.tax_code = "GST"
          self.taxModel = taxModel
        }
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
    }
  }
  
  /// 获取默认的负责员工
  func getBusiness() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Employee, path: .getBusiness,isNeedToast: false)
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByCodable(BusinessManModel.self, from: data) {
          self.staffModel = model
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode BusinessManModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
    }
  }
  
  func checkoutTOrder() -> Promise<Void> {
    Promise.init { resolver in
      
      if staffModel == nil {
        resolver.reject(APIError.requestError(code: -1, message: "The default responsible employee has not been obtained"))
        return
      }
      
      if taxModel == nil {
        resolver.reject(APIError.requestError(code: -1, message: "The current tax rate has not been obtained"))
        return
      }
      
      let mapParams = SOAPParams(action: .Sale, path: .checkoutTOrder)
      
      let data = SOAPDictionary()
      
      let clientInfo = SOAPDictionary()
      data.set(key: "Client_Info", value: clientInfo.result, keyType: .string, valueType: .map(1))
      
      let orderInfo = SOAPDictionary()
      orderInfo.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      orderInfo.set(key: "location_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      orderInfo.set(key: "customer_id", value: Defaults.shared.get(for: .clientId) ?? "")
      orderInfo.set(key: "subtotal", value: updateFooterViewData())
      orderInfo.set(key: "total", value: updateFooterViewData())
      orderInfo.set(key: "category", value: 2)
      orderInfo.set(key: "type", value: 1)
      orderInfo.set(key: "status", value: 0)
      orderInfo.set(key: "invoice_date", value: dateHMS)
      orderInfo.set(key: "due_date", value: dateYMD)
      orderInfo.set(key: "create_time", value: dateHMS)
      orderInfo.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
      orderInfo.set(key: "is_delete", value: "0")
      orderInfo.set(key: "is_from_app", value: "1")
      data.set(key: "Order_Info", value: orderInfo.result, keyType: .string, valueType: .map(1))
      
      let orderLines = SOAPDictionary()
      
      (self.dataArray as! [ShopCartModel]).enumerated().forEach { [weak self] i,e in
        guard let `self` = self else { return }
        
        let orderLine0 = SOAPDictionary()
        let orderLineItem = SOAPDictionary()
        
        orderLineItem.set(key: "product_category", value: e.product_category == "0" ? "5" : "1")
        orderLineItem.set(key: "product_id", value: e.goods_id)
        orderLineItem.set(key: "name", value: e.name)
        orderLineItem.set(key: "location_id", value: Defaults.shared.get(for: .companyId) ?? "97")
        orderLineItem.set(key: "price", value: e.sell_price)
        orderLineItem.set(key: "qty", value: e.goods_num)
        orderLineItem.set(key: "present_qty", value: 0)
        orderLineItem.set(key: "product_unit_id", value: "")
        orderLineItem.set(key: "discount_id", value: 0)
        orderLineItem.set(key: "discount_id2", value: 0)
        orderLineItem.set(key: "tax_id", value: self.taxModel?.id ?? "")
        
        let voucher = e.sell_price.float() ?? 0
        let rate = self.taxModel?.rate?.float() ?? 0
        let tax = (voucher - (voucher / (1 + rate / 100)))
        orderLineItem.set(key: "tax", value: tax)
        
        orderLineItem.set(key: "tax_is_include", value: 1)
        orderLineItem.set(key: "total", value: e.goods_num)
        orderLineItem.set(key: "cost", value: voucher)
        orderLineItem.set(key: "retail_price", value: voucher)
        orderLineItem.set(key: "staff_id", value: self.staffModel?.id ?? "")
        orderLineItem.set(key: "staff_id2", value: 0)
        orderLineItem.set(key: "appoint_sale_id", value: "")
        orderLineItem.set(key: "responsible_doctor", value: 0)
        orderLineItem.set(key: "referrer", value: 0)
        orderLineItem.set(key: "equal_staffs", value: "")
        orderLineItem.set(key: "collection_method", value: "")
        orderLineItem.set(key: "has_delivered", value: "")
        orderLineItem.set(key: "create_time", value: dateHMS)
        orderLineItem.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
        orderLineItem.set(key: "is_delete", value: "0")
        orderLineItem.set(key: "delivery_time", value: "")
        orderLineItem.set(key: "delivery_location_id", value: "")
       
        orderLine0.set(key: "data", value: orderLineItem.result, keyType: .string, valueType: .map(1))
        
        orderLines.set(key: i.string, value: orderLine0.result, keyType: .string, valueType: .map(1))
      }
      
      data.set(key: "Order_Lines", value: orderLines.result, keyType: .string, valueType: .map(1))
      
      mapParams.set(key: "data", value: data.result, type: .map(1))
      
      let logData = SOAPDictionary()
      logData.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
      mapParams.set(key: "logData", value: logData.result, type: .map(2))
      
      NetworkManager().request(params: mapParams) { data in
        if let id = JSON.init(from: data)?.rawString() {
          let vc = ShopCheckOutController(orderId: id, products: self.dataArray as! [ShopCartModel])
          self.navigationController?.pushViewController(vc)
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Failed to generate order"))
        }
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: e.localizedDescription))
      }
      
    }
  }
  
}

extension ShopCartController:SwipeTableViewCellDelegate {
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    if orientation == .right {
      let delete = SwipeAction(style: .destructive, title: nil) { a, i in
        Haptic.impact(.light).generate()
        let model = (self.dataArray as! [ShopCartModel])[indexPath.row]
        AlertView.show(title: "", message: "Are you sure you want to remove this item?", leftButtonTitle: "No", rightButtonTitle: "Yes", messageAlignment: .center, leftHandler: nil, rightHandler: {
          self.deleteProduct(model)
        }, dismissHandler: nil)
      }
      delete.image = R.image.notification_swip_delete()
      delete.backgroundColor = .white
      
      return [delete]
    }
   return nil
  }
  
  func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeOptions()
    options.backgroundColor = .white
    
    return options
    
  }
}
