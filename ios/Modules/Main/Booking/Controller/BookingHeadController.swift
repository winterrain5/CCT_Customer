//
//  BookingHeadController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/13.
//

import UIKit

class BookingHeadController: BaseViewController {
  var headLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.text = "Today's Session"
    label.font = UIFont(name: .AvenirNextDemiBold, size: 24)
    label.lineHeight = 36
  }
  var dateLabel = UILabel().then { label in
    label.textColor = R.color.gray82()
    label.text = Date().string(withFormat: "dd MMM yyyy,EEE")
    label.font = UIFont(name: .AvenirNextRegular, size: 16)
    label.lineHeight = 24
  }
  var sessionView = TodaySessionView()
  var additionalH:CGFloat = 0
  var models:[BookingTodayModel] = [] {
    didSet {
      sessionView.models = models
      layoutViews()
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.clipsToBounds = true
    self.view.addSubview(headLabel)
  
    self.view.addSubview(dateLabel)
 
    self.view.addSubview(sessionView)
  
  }
  
  
  func layoutViews() {
    headLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(24)
    }
    dateLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(headLabel.snp.bottom)
    }
    sessionView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalToSuperview().offset(94)
      make.height.equalTo(sessionView.todayHeight)
    }
  }
  
}
