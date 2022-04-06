//
//  MyOrderDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit
import PromiseKit

class MyOrderDetailController: BaseViewController {
  
  private var scrollView = UIScrollView()
  private var headerView = MyOrderDetailHeaderView.loadViewFromNib()
  private var footerView = MyOrderDetailFooterView.loadViewFromNib()
  private var helpButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.titleForNormal = "Need Help?"
  }
  private var status:Int = 0
  private var orderModel:MyOrderModel!
  convenience init(status:Int,orderModel:MyOrderModel) {
    self.init()
    self.status = status
    self.orderModel = orderModel
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "My Orders"
    
    self.view.addSubview(scrollView)
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    scrollView.contentSize = CGSize(width: kScreenWidth, height: 0)
    
    scrollView.addSubview(headerView)
    headerView.status = status
    headerView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 0)
    headerView.updateHeightHandler = { [weak self] height in
      self?.headerView.height = height
      self?.scrollView.contentSize.height += height
    }
    
    scrollView.addSubview(footerView)
    footerView.frame = CGRect(x: 0, y: headerView.frame.maxY, width: kScreenWidth, height: 0)
    footerView.updateHeightHandler = { [weak self] height in
      self?.footerView.height = height
      self?.footerView.frame.origin.y = self?.headerView.frame.maxY ?? 0
      self?.scrollView.contentSize.height += height
    }
    
    self.view.addSubview(helpButton)
    helpButton.addTarget(self, action: #selector(helpButtonAction), for: .touchUpInside)
    helpButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(32)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(40 + kBottomsafeAreaMargin)
    }
    
    scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84 + kBottomsafeAreaMargin, right: 0)
    
    NotificationCenter.default.addObserver(self, selector: #selector(reviewComplte), name: NSNotification.Name.reviewOrderComplete, object: nil)
    
    refreshData()
  }
  
  @objc func reviewComplte() {
    refreshData()
  }
  
  func refreshData() {
    when(fulfilled: getTSystemConfig(),getOrderDetail()).done { [weak self] points,detail in
      self?.headerView.leaveReviewPoints = String(points.split(separator: ".").first ?? "")
      self?.headerView.model = detail
      self?.footerView.model = detail
    }.catch { e in
      Toast.showError(withStatus: e.asAPIError.errorInfo().message)
    }
  }
  
  func getTSystemConfig() -> Promise<String>{
    
    Promise.init { resolver in
      let params = SOAPParams(action: .SystemConfig, path: .getTSystemConfig)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByCodable(SystemConfigModel.self, from: data) {
          resolver.fulfill(model.leave_review_points?.string ?? "")
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode SystemConfigModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
    
  }
  
  func getOrderDetail() -> Promise<MyOrderDetailModel> {
    Promise.init { resolver in
      var path:API!
      if orderModel.type == "5" {
        path = .getHistoryCheckoutDetails
      }else {
        path = .getHistoryOrderDetails
      }
      let params = SOAPParams(action: .Sale, path: path)
      params.set(key: "orderId", value: orderModel.id ?? "")
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByHandJSON(MyOrderDetailModel.self, from: data) {
          resolver.fulfill(model)
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode MyOrderDetailModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  @objc func helpButtonAction() {
    let vc = QuestionHelperController()
    self.navigationController?.pushViewController(vc)
  }
  
  
  
}
