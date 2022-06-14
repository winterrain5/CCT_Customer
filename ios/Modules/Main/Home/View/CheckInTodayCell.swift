//
//  CheckInTodayCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/14.
//

import UIKit

class CheckInTodayCell: UICollectionViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var timeLabel: UILabel!
  
  var checkInHandler:((BookingTodayModel)->())?
  var model:BookingTodayModel! {
    didSet {
      
      let date = model.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      timeLabel.text = date?.timeString(ofStyle: .short)
      titleLabel.text = model.alias_name
    
    }
  }
  override func awakeFromNib() {
        super.awakeFromNib()
    contentView.cornerRadius = 16
    }

  @IBAction func checkAction(_ sender: Any) {
    checkInHandler?(model)
  }
}
