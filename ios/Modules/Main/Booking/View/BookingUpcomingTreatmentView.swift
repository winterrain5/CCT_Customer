//
//  BookingUpcomingTreatmentView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/17.
//

import UIKit

class BookingUpcomingTreatmentView: UIView {

  @IBOutlet weak var shadowView4: UIView!
  @IBOutlet weak var SmptomsLabel: UILabel!
  @IBOutlet weak var lastActivityLabel: UILabel!
  @IBOutlet weak var areaOfPainLabel: UILabel!
  @IBOutlet weak var shaodwV2HCons: NSLayoutConstraint!
  @IBOutlet weak var shadowV4TopsCons: NSLayoutConstraint!
  @IBOutlet weak var shadowV3TopCons: NSLayoutConstraint!
  @IBOutlet weak var shaowV1HCons: NSLayoutConstraint!
  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var remarkLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var cancelButton: LoadingButton!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var checkinButton: UIButton!
  @IBOutlet weak var shadowView1: UIView!
  @IBOutlet weak var shadowView3: UIView!
  @IBOutlet weak var whatsappLabel: UILabel!
  @IBOutlet weak var shadowView2: UIView!
  var isCanCheckIn:Bool = false
  var checkInHandler:((BookingTodayModel)->())?
  var upcoming:BookingUpComingModel? {
    didSet {
      guard let upcoming = upcoming else {
        return
      }
      nameLabel.text = upcoming.alias_name
      if let date = upcoming.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss") {
        dateLabel.text = date.string(withFormat: "dd MMM yyyy,EEE - ").appending(date.timeString(ofStyle: .short))
        isCanCheckIn = date.isInToday
      }
      locationLabel.text = upcoming.location_alias_name.isEmpty ? upcoming.location_name : upcoming.location_alias_name
      self.updateCheckinButtonStatus()
      self.updateRemarkData(upcoming.remark)
      layoutIfNeeded()
    }
  }
  
  var today:BookingTodayModel? {
    didSet {
      guard let today = today else {
        return
      }
      nameLabel.text = today.alias_name
      if let date = today.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss") {
        dateLabel.text = date.string(withFormat: "dd MMM yyyy,EEE - ").appending(date.timeString(ofStyle: .short))
        isCanCheckIn = date.isInToday
      }
      locationLabel.text = today.location_alias_name.isEmpty ? today.location_name : today.location_alias_name
      self.updateCheckinButtonStatus()
      self.updateRemarkData(today.remark)
      layoutIfNeeded()
    }
  }
  
  var company:CompanyModel! {
    didSet {
      phoneLabel.text = company.phone
      whatsappLabel.text = company.whatapp
    }
  }
  
  var result:[[SymptomCheckStepModel]] = [] {
    didSet {
      shadowView4.isHidden = result.isEmpty
      
      if result.isEmpty {
        shadowV3TopCons.constant = 16
        layoutIfNeeded()
        return
      }
      let symptoms = result.first?.map({$0.title ?? ""}).reduce("", { $0 + "\n" + $1}).removingPrefix("\n")
      let lastActivity = result[1].first?.title ?? ""
      let area = result[2].map({$0.title ?? ""}).reduce("", { $0 + "\n" + $1}).removingPrefix("\n")
      
      SmptomsLabel.text = symptoms
      lastActivityLabel.text = lastActivity
      areaOfPainLabel.text = area
      layoutIfNeeded()
      
    }
  }
  var updateHeightHandler:((CGFloat)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView1.addLightShadow(by: 16)
    shadowView2.addLightShadow(by: 16)
    shadowView3.addLightShadow(by: 16)
    shadowView4.addLightShadow(by: 16)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topRight,.topLeft], radii: 16)
    shadowV3TopCons.constant = shadowView4.height + 16
    updateHeightHandler?(checkinButton.frame.maxY + 80 + kBottomsafeAreaMargin)
  }
  
  func updateRemarkData(_ remark:String) {
    if remark.isEmpty {
      shadowView2.isHidden = true
      shadowV4TopsCons.constant = 16
      shaodwV2HCons.constant = 0
    }else {
      shadowView2.isHidden = false
      let remarkH = remark.heightWithConstrainedWidth(width: kScreenWidth - 80, font: UIFont(name: .AvenirNextRegular, size: 14)) + 8
      let s2h = remarkH + 56
      shaodwV2HCons.constant = s2h
      shadowV4TopsCons.constant = s2h + 32
    }
    
    remarkLabel.text = remark
  }
  
  func updateCheckinButtonStatus() {
    if isCanCheckIn {
      checkinButton.backgroundColor = R.color.theamRed()
      checkinButton.isEnabled = true
    }else {
      checkinButton.backgroundColor = R.color.placeholder()
      checkinButton.isEnabled = false
    }
 
  }
  
  @IBAction func phoneAction(_ sender: Any) {
    CallUtil.callPhone(company.phone)
  }
  
  @IBAction func whatsappAction(_ sender: Any) {
    CallUtil.callWhatsapp(company.whatapp)
  }
  
  @IBAction func cancelAction(_ sender: LoadingButton) {
    
    let date = self.upcoming == nil ? self.today?.therapy_start_date : self.upcoming?.therapy_start_date
    let hour = date?.dateTime?.hoursSince(Date()) ?? 0
    // 48小时内取消 获取预约次数
    if hour <= 48 {
      getClientCancelCount()
    }else {
      AlertView.show(title: "Are you sure you want to cancel?", message: "", leftButtonTitle: "Back", rightButtonTitle: "Confirm", messageAlignment: .center, leftHandler: nil, rightHandler: {
       
        self.cancelRequest(0)
        
        
      }, dismissHandler: nil)
    }
    
  }
  
  func getClientCancelCount() {
    let params = SOAPParams(action: .Client, path: .getClientCancelCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      let count = JSON.init(from: data)?["cancel_count"].rawString()?.int ?? 0
    
      let content = "Your cancellation is less than 48 hours from the scheduled appointment. You have \(count) late cancellation(s), your in app booking privileges will be suspended after performing 3 late cancellations. "
      
      let attrStr = NSMutableAttributedString(string: content)
      attrStr.addAttributes([.font:UIFont(name: .AvenirNextRegular,size: 16)], range: NSRange(location: 0, length: content.count))
      attrStr.addAttributes([.foregroundColor:R.color.black333()!], range: NSRange(location: 0, length: content.count))
      attrStr.addAttributes([.font:UIFont(name: .AvenirNextDemiBold,size: 16)], range: NSRange(location: 31, length: 8))
      attrStr.addAttributes([.font:UIFont(name: .AvenirNextDemiBold,size: 16)], range: NSRange(location: 81, length: 1))
      attrStr.addAttributes([.font:UIFont(name: .AvenirNextDemiBold,size: 16)], range: NSRange(location: 171, length: 1))

    
      AlertView.show(title: "Are you sure you want to cancel?", message: attrStr, leftButtonTitle: "Back", rightButtonTitle: "Confirm", messageAlignment: .left, leftHandler: nil, rightHandler: {
        self.cancelRequest(1)
      }, dismissHandler: nil)
      
    } errorHandler: { e in
      Toast.dismiss()
    }

    
  }
  
  func cancelRequest(_ isReach:Int) {
    let params = SOAPParams(action: .BookingOrder, path: .cancelAppointments)
    
    let id = upcoming == nil ? today?.id : upcoming?.id
    let date = upcoming == nil ? today?.therapy_start_date : upcoming?.therapy_start_date
    params.set(key: "id", value: id ?? "")
    params.set(key: "startDate", value: date ?? "")
    params.set(key: "isCancelUpcoming", value: upcoming == nil ? "0" : "1")
    
    let data = SOAPDictionary()
    data.set(key: "cancel_reason_id", value: 0)
    data.set(key: "cancel_date", value: Date().string(withFormat: "yyyy-MM-dd HH:mm:ss"))
    data.set(key: "cancel_uid", value: Defaults.shared.get(for: .clientId) ?? "")
    data.set(key: "isReach", value: isReach)
    data.set(key: "remarks", value: "在手机端取消")
    
    params.set(key: "data", value: data.result,type: .map(1))
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      UIViewController.getTopVc()?.navigationController?.popViewController()
      NotificationCenter.default.post(name: .bookingDataChanged, object: nil)
    } errorHandler: { e in
      Toast.dismiss()
    }

  }
  
  @IBAction func checkinAction(_ sender: Any) {
    if let today = today {
      checkInHandler?(today)
    }
    
  }
  
}
