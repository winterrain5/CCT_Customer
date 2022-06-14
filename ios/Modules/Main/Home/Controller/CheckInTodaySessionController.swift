//
//  CheckInTodaySessionController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/14.
//

import UIKit

class CheckInTodaySessionController: BaseViewController {
  
  var contentView = CheckInTodaySessionView.loadViewFromNib()
  var locatioName = ""
  init(locationName:String) {
    super.init(nibName: nil, bundle: nil)
    self.locatioName = locationName
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(contentView)
    contentView.titleLabel.text = "Check in today's session at \(locatioName)"
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
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
