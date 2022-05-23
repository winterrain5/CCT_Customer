//
//  BookingCompleteDetailController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/19.
//

import UIKit

class BookingCompleteDetailController: BaseViewController {

  let contentView = BookingCompleteDetailView.loadViewFromNib()
  var complete: BookingCompleteModel!
  
  var scrolView = UIScrollView()
  var button = UIButton().then { btn in
    btn.backgroundColor = R.color.theamBlue()
    btn.titleForNormal = "Leave Feedback"
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size: 16)
    btn.cornerRadius = 22
    btn.isHidden = true
  }
  
  convenience init(complete:BookingCompleteModel) {
    self.init()
    self.complete = complete
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.isSkeletonable = true
    self.view.backgroundColor = R.color.theamBlue()
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    
    self.view.addSubview(scrolView)
    scrolView.isSkeletonable = true
    scrolView.bounces = false
    scrolView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight)
    scrolView.contentSize = CGSize(width: kScreenWidth, height: kScreenHeight)
    scrolView.backgroundColor = .clear
    
    scrolView.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    contentView.heightUpdateHandler = { [weak self] height in
      guard let `self` = self else { return }
      let originH = self.contentView.frame.size.height
      let realH = height < originH ? originH : height
      self.contentView.frame.size.height = realH
      self.scrolView.contentSize.height = realH
      
    }
    
    self.view.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().offset(-(kBottomsafeAreaMargin + 40))
      make.height.equalTo(44)
    }
    
    getOrderDetails()
  }
    

  
  func getOrderDetails() {
    let params = SOAPParams(action: .Sale, path: .getHistoryOrderDetails)
    params.set(key: "orderId", value: complete.id)
    self.view.showSkeleton()
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(MyOrderDetailModel.self, from: data) {
        self.contentView.complete = self.complete
        self.contentView.model = model
      }else {
        Toast.showError(withStatus: "Decode MyOrderDetailModel Failed")
      }
      self.view.hideSkeleton()
    } errorHandler: { e in
      self.view.hideSkeleton()
    }

  }
  

}
