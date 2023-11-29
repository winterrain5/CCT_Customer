//
//  ConfirmSessionController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/24.
//

import UIKit
import PromiseKit
import SideMenuSwift
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
    
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.backgroundColor = R.color.theamBlue()
    
    self.view.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    contentView.confirmHandler = { [weak self] in
      guard let `self` = self else { return }
      if ((self.navigationController?.children.contains(where: { $0 is LoginViewController })) != nil) {
        let tab = BaseTabBarController()
        UIApplication.shared.keyWindow?.rootViewController = SideMenuController(contentViewController: tab, menuViewController: MenuViewController())
      }else {
        self.navigationController?.popToRootViewController(animated: true)
      }
      
      
    }
    
    if let todayModel = todayModel {
      if todayModel.wellness_treatment_type == "2" { // 获取排队信息
        when(fulfilled: getWaitServiceInfo(), getTClientPartInfo()).done { [weak self] in
          self?.contentView.todayModel = todayModel
        }.catch { e in
          print(e)
        }
      }else {
        getTClientPartInfo().done { [weak self] _ in
          self?.contentView.todayModel = todayModel
        }.catch { e in
          print(e)
        }
      }
    }else {
      getTClientPartInfo().done { [weak self] _ in
        guard let `self` = self else { return }
        if let user = Defaults.shared.get(for: .userModel) {
          self.params?.user_name = user.first_name + " " + user.last_name
          self.params?.user_gender = user.gender == "1" ? "Male" : "Female"
          self.params?.user_birth_day = user.birthday.date?.string(withFormat: "dd MMM yyyy") ?? ""
          self.params?.user_passport = user.card_number
        }
        self.contentView.model = self.params
      }.catch { e in
        print(e)
      }
      
    }
  }
  
  
  func getWaitServiceInfo() -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .BookingOrder, path: .getWaitServiceInfo)
      params.set(key: "locationId", value: todayModel?.location_id ?? "")
      params.set(key: "startTime", value: Date().string(withFormat: "yyyy-MM-dd"))
      params.set(key: "endTime", value: Date().adding(.day, value: 1).string(withFormat: "yyyy-MM-dd"))
      params.set(key: "wellnessTreatType", value: 2)
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(WaitServiceModel.self, from: data) {
          self.todayModel?.queue_count = model.queue_count
          self.todayModel?.duration_mins = model.duration_mins
          resolver.fulfill_()
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "decode WaitServiceModel failed"))
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
    
  }
  
  func getTClientPartInfo() -> Promise<Void> {
    Promise.init { resolver in
      
      
      if let user = Defaults.shared.get(for: .userModel),!user.user_id.isEmpty {
        resolver.fulfill_()
        return
      }
      
      let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
          Defaults.shared.set(model, for: .userModel)
          resolver.fulfill_()
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "GetTClientPartInfo Failed"))
        
      } errorHandler: { e in
        resolver.fulfill_()
      }
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
