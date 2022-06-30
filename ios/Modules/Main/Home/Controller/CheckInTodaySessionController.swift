//
//  CheckInTodaySessionController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/14.
//

import UIKit

class CheckInTodaySessionController: BaseViewController {
  
  var contentView = CheckInTodaySessionView.loadViewFromNib()
  var scrollView = UIScrollView()
  var outlet:(id:String,name:String)?
  convenience init(outlet:(id:String,name:String)?) {
    self.init()
    self.outlet = outlet
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.interactivePopGestureRecognizerEnable = false
    
    self.view.isSkeletonable = true
    self.view.backgroundColor = R.color.theamBlue()
    self.view.addSubview(scrollView)
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    scrollView.contentSize = CGSize(width: kScreenWidth, height: 732)
    
    scrollView.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 732)
    contentView.outlet = outlet
    getTodaySession()
  }
  
  func getTodaySession() {
    let params = SOAPParams(action: .BookingOrder, path: .getClientBookedServices)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "date", value: Date().string(withFormat: "yyyy-MM-dd"))
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(BookingTodayModel.self, from: data) {
        self.contentView.models = models
      }
    } errorHandler: { e in
      
    }
  }
  
}
