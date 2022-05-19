//
//  BookingUpComingDetailController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/17.
//

import UIKit

class BookingUpComingDetailController: BaseViewController {
  
  let contentView = BookingUpComingDetailView.loadViewFromNib()
  var upcoming: BookingUpComingModel?
  var today: BookingTodayModel?
  
  convenience init(upcoming:BookingUpComingModel) {
    self.init()
    self.upcoming = upcoming
  }
  
  convenience init(today:BookingTodayModel) {
    self.init()
    self.today = today
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.isSkeletonable = true
    self.view.backgroundColor = R.color.theamBlue()
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    
    getCompanyInfo()
  }
  
  
  func getCompanyInfo() {
    let params = SOAPParams(action: .Company, path: .getTCompany)
    var id:String = ""
    if upcoming != nil {
      id = upcoming?.location_id ?? ""
    }
    if today != nil {
      id = today?.location_id ?? ""
    }
    params.set(key: "id", value: id)
    self.view.showSkeleton()
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(CompanyModel.self, from: data) {
        self.contentView.company = model
        self.contentView.upcoming = self.upcoming
        self.contentView.today = self.today
      }
      self.view.hideSkeleton()
    } errorHandler: { e in
      self.view.hideSkeleton()
    }

  }
  
}
