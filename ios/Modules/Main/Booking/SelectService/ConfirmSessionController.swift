//
//  ConfirmSessionController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/24.
//

import UIKit

class ConfirmSessionController: BaseViewController {
  
  var contentView = ConfirmSessionContainer.loadViewFromNib()
  var params:ConfirmSessionModel?
  var todayModel:BookingTodayModel?
  convenience init(params:ConfirmSessionModel) {
    self.init()
    self.params = params
  }
  convenience init(todayModel:BookingTodayModel) {
    self.init()
    self.todayModel = todayModel
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.interactivePopGestureRecognizerEnable = false
    
    self.addLeftBarButtonItem(R.image.return_left())
    self.leftButtonDidClick = { [weak self] in
      self?.navigationController?.popToRootViewController(animated: true)
    }
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.backgroundColor = R.color.theamBlue()
    
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    contentView.model = params
    contentView.confirmHandler = { [weak self] in
      guard let `self` = self else { return }
      self.navigationController?.popToRootViewController(animated: true)
      
    }
    
    if let todayModel = todayModel {
      if todayModel.wellness_treatment_type == "2" { // 获取排队信息
        getWaitServiceInfo()
      }else {
        contentView.todayModel = todayModel
      }
    }
  }
  
  
  func getWaitServiceInfo() {
    let params = SOAPParams(action: .BookingOrder, path: .getWaitServiceInfo)
    params.set(key: "locationId", value: todayModel?.location_id ?? "")
    params.set(key: "startTime", value: Date().string(withFormat: "yyyy-MM-dd"))
    params.set(key: "endTime", value: Date().adding(.day, value: 1).string(withFormat: "yyyy-MM-dd"))
    params.set(key: "wellnessTreatType", value: 2)
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(WaitServiceModel.self, from: data) {
        self.todayModel?.queue_count = model.queue_count
        self.todayModel?.duration_mins = model.duration_mins
        self.contentView.todayModel = self.todayModel
      }
    } errorHandler: { e in
      
    }

  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  
  
}

class WaitServiceModel:BaseModel {
  var queue_count = "0"
  var duration_mins = "0"
}
