//
//  TodayWellnessCheckSessionCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/16.
//

import UIKit

class TodayWellnessCheckSessionCell: UICollectionViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var infoContentView: UIView!
  @IBOutlet weak var locationView: UIView!

  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var employeeNameLabel: UILabel!
  @IBOutlet weak var employeeView: UIView!
  
  @IBOutlet weak var bottomLabelTopCons: NSLayoutConstraint!
  var model:BookingTodayModel! {
    didSet {
      let date = model.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      timeLabel.text = date?.timeString(ofStyle: .short)
      locationLabel.text = model.location_alias_name.isEmpty ? model.location_name : model.location_alias_name
      nameLabel.text = model.alias_name
      employeeNameLabel.text = model.staff_name
      employeeView.isHidden = model.staff_is_random == "1"
      bottomLabelTopCons.constant = model.staff_is_random == "1" ? 8 : 36
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
