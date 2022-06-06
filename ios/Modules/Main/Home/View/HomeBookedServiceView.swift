//
//  HomeBookedServiceView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/6.
//

import UIKit
import SideMenuSwift
class HomeBookedServiceView: UIView {

  var titleLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 24)
  }
  var viewAllBtn = UIButton().then { btn in
    btn.titleForNormal = "View All"
    btn.titleColorForNormal = R.color.theamRed()
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size: 14)
  }
  
  var upcomingView = UpcomingSessionView()
  var todayView = TodaySessionView()
 
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)
    addSubview(viewAllBtn)
    viewAllBtn.addTarget(self, action: #selector(viewAllAction), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(32)
      make.height.equalTo(36)
    }
    viewAllBtn.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(24)
      make.height.equalTo(36)
      make.centerY.equalTo(titleLabel)
    }
  }
  
  @objc func viewAllAction() {
    let menu = UIViewController.getTopVC() as? SideMenuController
    (menu?.contentViewController as? BaseTabBarController)?.selectedIndex = 1
  }
  
  var contentH:CGFloat = 0
  func updateAppointmentViewData(viewType:AppointmentViewType,today:[BookingTodayModel] = [],upcoming:[BookingUpComingModel] = []) {
    contentH = 88
    var sessionH:CGFloat = 0
    todayView.removeFromSuperview()
    upcomingView.removeFromSuperview()
    if viewType == .Today {
      addSubview(todayView)
      todayView.models = today
      sessionH = todayView.todayHeight
      todayView.snp.makeConstraints { make in
        make.left.right.equalToSuperview()
        make.top.equalTo(titleLabel.snp.bottom).offset(16)
        make.height.equalTo(sessionH)
      }
      titleLabel.text = "Today's Session"
    }
    if viewType == .Upcoming {
      addSubview(upcomingView)
      upcomingView.models = upcoming
      sessionH = upcomingView.upcomingHeight
      upcomingView.snp.makeConstraints { make in
        make.left.right.equalToSuperview()
        make.top.equalTo(titleLabel.snp.bottom).offset(16)
        make.height.equalTo(sessionH)
      }
      titleLabel.text = "Upcoming Session"
    }
    contentH += sessionH
  }
}
