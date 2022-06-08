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
  var model:BookingUpComingModel! {
    didSet {
      let date = model.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      timeLabel.text = date?.timeString(ofStyle: .short)
      dateLabel.text = date?.string(withFormat: "dd MMM yyyy,EEE")
      locationLabel.text = model.location_name
      nameLabel.text = model.alias_name
      employeeNameLabel.text = model.employee_first_name + " " + model.employee_last_name
      employeeView.isHidden = model.staff_is_random == "1"
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
