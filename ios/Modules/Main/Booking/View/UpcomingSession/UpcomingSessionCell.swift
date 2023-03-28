//
//  UpcomingSessionCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/8.
//

import UIKit

class UpcomingSessionCell: UICollectionViewCell {

  @IBOutlet weak var infoContentView: UIView!
  @IBOutlet weak var locationView: UIView!
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var employeeNameLabel: UILabel!
  @IBOutlet weak var employeeView: UIView!
  @IBOutlet weak var genderImageView: UIImageView!
  var model:BookingUpComingModel! {
    didSet {
      if let date = model.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss") {
        timeLabel.text = date.timeString(ofStyle: .short)
        dateLabel.text = date.string(withFormat: "dd MMM yyyy,EEE")
      }
      
      nameLabel.text = model.alias_name
      employeeNameLabel.text = model.employee_first_name + " " + model.employee_last_name
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
      
      setNeedsLayout()
      layoutIfNeeded()
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


}
