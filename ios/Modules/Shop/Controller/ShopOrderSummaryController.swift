//
//  ShopOrderSummaryController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/26.
//

import UIKit
import PromiseKit
class ShopOrderSummaryController: BaseViewController {

  private var scrollView = UIScrollView()
  private var textLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextDemiBold,24)
    label.text = "Your order has been confirmed!"
    label.textAlignment = .center
    label.numberOfLines = 2
  }
  private var headerView = MyOrderDetailHeaderView.loadViewFromNib()
  private var footerView = MyOrderDetailFooterView.loadViewFromNib()
  private var returnButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.titleForNormal = "Return to Shop"
  }
  private var id = ""
  convenience init(id:String) {
    self.init()
    self.id = id
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Order Summary"
    
    self.view.addSubview(scrollView)
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    scrollView.contentSize = CGSize(width: kScreenWidth, height: 0)
    
    scrollView.addSubview(textLabel)
    textLabel.frame = CGRect(x: 16, y: 0, width: kScreenWidth - 32, height: 114)
    self.scrollView.contentSize.height += 114
    
    scrollView.addSubview(headerView)
    headerView.status = 1
    headerView.frame = CGRect(x: 0, y: textLabel.frame.maxY, width: kScreenWidth, height: 0)
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
    
    self.view.addSubview(returnButton)
    (returnButton).addTarget(self, action: #selector(returnButtonAction), for: .touchUpInside)
    (returnButton).snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(32)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(40 + kBottomsafeAreaMargin)
    }
    
    scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84 + kBottomsafeAreaMargin, right: 0)
    
    NotificationCenter.default.addObserver(self, selector: #selector(reviewComplte), name: NSNotification.Name.reviewOrderComplete, object: nil)
    
    
    addLeftBarButtonItem()
    leftButtonDidClick = { [weak self] in
      self?.returnButtonAction()
    }
    
    interactivePopGestureRecognizerEnable = false
    
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
     
      let params = SOAPParams(action: .Sale, path: .getHistoryOrderDetails)
      params.set(key: "orderId", value: id)
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(MyOrderDetailModel.self, from: data) {
          resolver.fulfill(model)
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode MyOrderDetailModel Failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  @objc func returnButtonAction() {
    self.navigationController?.viewControllers.forEach({ vc in
      if vc is ShopViewController {
        self.navigationController?.popToViewController(vc, animated: true)
      }
    })
  }
    

 

}
