//
//  TodaySessionCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/18.
//

import UIKit

class TodayCheckInCell: UICollectionViewCell {

  @IBOutlet weak var infoContentView: UIView!
  @IBOutlet weak var locationView: UIView!
  
  @IBOutlet weak var genderImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var employeeNameLabel: UILabel!
  @IBOutlet weak var employeeView: UIView!
  var model:BookingTodayModel! {
    didSet {
      let date = model.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      timeLabel.text = date?.timeString(ofStyle: .short)
      employeeNameLabel.text = model.staff_name
      nameLabel.text = model.alias_name
      employeeView.isHidden = model.staff_is_random == "1"
      
      if model.work_status == "2" { // 外出
        locationLabel.text = model.address
      }else {
        locationLabel.text = model.location_alias_name.isEmpty ? model.location_name : model.location_alias_name
      }
      
      let genderImage = model.gender == "1" ? R.image.booking_user() : R.image.woman()
      let genderColor = model.gender == "1" ? kManFontColor : kWomanFontColor
      genderImageView.image = genderImage
      employeeNameLabel.textColor = genderColor
      
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    infoContentView.addLightShadow(by: 16)
   
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    locationView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func checkinAction(_ sender: Any) {
    NotificationCenter.default.post(name: NSNotification.Name.todayCheckIn, object: self.model)
  }
}
