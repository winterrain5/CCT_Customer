//
//  ServiceDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit
import PromiseKit
class ServiceDetailController: BaseViewController {
  
  private var scrollView = UIScrollView().then { view in
    view.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
  }
  private var headView = ServiceDetailHeaderView.loadViewFromNib()
  private var priceView = ServiceDetailPriceView.loadViewFromNib()
  private var helpView = ServiceDetailHelpView.loadViewFromNib()
  private var forWhoView = ServiceDetailForWhoView.loadViewFromNib()
  private var footerView = ServiceDetailFooterView.loadViewFromNib()
  private var serviceId:String = ""
  init(serviceId:String) {
    super.init(nibName: nil, bundle: nil)
    self.serviceId = serviceId
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Service"
    
    view.addSubview(scrollView)
    scrollView.contentSize = self.view.size
    
    scrollView.addSubview(headView)
    headView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    headView.updateHandler = { [weak self] totalH in
      self?.headView.height = totalH
      self?.scrollView.contentSize.height = totalH
    }
    
    scrollView.addSubview(priceView)
    priceView.frame = CGRect(x: 16, y: headView.frame.maxY, width: kScreenWidth - 32, height: 0)
    priceView.updateHandler = { [weak self] totalH in
      self?.priceView.height = totalH
      self?.priceView.frame.origin.y = self?.headView.frame.maxY ?? 0
      self?.scrollView.contentSize.height += totalH
    }
    
    scrollView.addSubview(helpView)
    helpView.frame = CGRect(x: 0, y: priceView.frame.maxY, width: kScreenWidth, height: 0)
    helpView.updateHandler = { [weak self] totalH in
      self?.helpView.height = totalH
      self?.helpView.frame.origin.y = (self?.priceView.frame.maxY ?? 0) + 30
      self?.scrollView.contentSize.height += totalH
    }
    
    scrollView.addSubview(forWhoView)
    forWhoView.frame = CGRect(x: 0, y: helpView.frame.maxY, width: kScreenWidth, height: 0)
    forWhoView.updateHandler = { [weak self] totalH in
      self?.forWhoView.height = totalH
      self?.forWhoView.frame.origin.y = (self?.helpView.frame.maxY ?? 0)
      self?.scrollView.contentSize.height += totalH
    }
    
    scrollView.addSubview(footerView)
    footerView.frame = CGRect(x: 0, y: forWhoView.frame.maxY, width: kScreenWidth, height: 0)
    footerView.isHidden = true
    footerView.updateHandler = { [weak self] totalH in
      self?.footerView.height = totalH + 10
      self?.footerView.frame.origin.y = (self?.forWhoView.frame.maxY ?? 0)
      self?.scrollView.contentSize.height += totalH
    }
    
    refreshData()
  }
  

  
  func refreshData() {
    
    firstly{
      self.getBriefDataBySvrId()
    }.then { planid in
      self.getConditionPlanContent(planid)
    }.catch { e in
      Toast.showMessage(e.asAPIError.errorInfo().message)
    }
  }
  
  func getBriefDataBySvrId() -> Promise<String>{
    Promise.init { resolver in
      
      let params = SOAPParams(action: .Service, path: .getBriefDataBySvrId)
      params.set(key: "serviceId", value: serviceId)
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByCodable(ServiceDetailBrifeModel.self, from: data) {
          self.headView.model = model
          self.priceView.durations = model.durations
          self.helpView.helps = model.briefHelpItems ?? []
          self.forWhoView.brifeModel = model.briefData
          resolver.fulfill(model.briefData?.treatment_plan_id?.string ?? "")
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "decode ServiceDetailBrifeModel failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }

    }
  }
  
  func getConditionPlanContent(_ planId:String) -> Promise<Void>{
    Promise.init { resolver in
      
      let params = SOAPParams(action: .TreatConditions, path: .getConditionPlanContent)
      params.set(key: "planId", value: planId)
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByCodable(ServiceDetailTreatPlanModel.self, from: data) {
          self.footerView.isHidden = false
          self.footerView.plan = model.treatPlanData
          resolver.fulfill_()
        }else {
          resolver.reject(APIError.requestError(code: -1, message: "decode ServiceDetailBrifeModel failed"))
        }
      } errorHandler: { e in
        resolver.reject(e)
      }

    }
  }
  
}
