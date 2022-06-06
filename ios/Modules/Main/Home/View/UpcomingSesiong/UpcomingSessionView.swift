//
//  UpcomingSessionView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/6.
//

import UIKit

class UpcomingSessionView: UIView {
  var upcomingHeight:CGFloat = 0
  var models:[BookingUpComingModel] = [] {
    didSet {
      upcomingHeight = 0
      upcomingHeight = models.filter({ $0.staff_is_random == "2" }).count > 0 ? 186 : 160
      
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .red
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
}
