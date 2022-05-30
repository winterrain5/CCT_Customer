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
  var models:[BookingTodayModel] = [] {
    didSet {
      sessionView.models = models
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.clipsToBounds = true
    self.view.addSubview(headLabel)
    headLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(24)
    }
    self.view.addSubview(dateLabel)
    dateLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(headLabel.snp.bottom)
    }
    self.view.addSubview(sessionView)
    sessionView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalToSuperview().offset(94)
      make.height.equalTo(216)
    }
  }
  
  
  
  
}
