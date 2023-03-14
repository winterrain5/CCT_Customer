//
//  BookingUpComingCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/17.
//

import UIKit

class BookingUpComingCell: UITableViewCell {

  @IBOutlet weak var infoContentView: UIView!
  @IBOutlet weak var locationView: UIView!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var yearMonthLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var weeklabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var staffView: UIView!
  @IBOutlet weak var staffNameLabel: UILabel!
  @IBOutlet weak var genderImageView: UIImageView!
  var model:BookingUpComingModel! {
    didSet {
      let date = model.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      if let dateformates = date?.string(withFormat: "MMM yyyy dd EEE").split(separator: " ") {
        yearMonthLabel.text = dateformates[0] + " " + dateformates[1]
        dayLabel.text = String(dateformates[2])
        weeklabel.text = dateformates[3].uppercased()
        timeLabel.text = date?.timeString(ofStyle: .short)
      }
   
      nameLabel.text = model.alias_name
      if model.staff_is_random == "2" {
        staffView.isHidden = false
        staffNameLabel.text = model.employee_first_name + " " + model.employee_last_name
      }else {
        staffView.isHidden = true
      }
      
      if model.work_status == "2" { // 外出
        locationLabel.text = model.address
      }else {
        locationLabel.text = model.location_alias_name.isEmpty ? model.location_name : model.location_alias_name
      }
      
      let genderImage = model.gender == "1" ? R.image.booking_user() : R.image.woman()
      let genderColor = model.gender == "1" ? kManFontColor : kWomanFontColor
      genderImageView.image = genderImage
      staffNameLabel.textColor = genderColor
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
