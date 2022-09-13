//
//  BookingCompletedCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/13.
//

import UIKit

class BookingCompletedCell: UITableViewCell {
  
  @IBOutlet weak var infoContentView: UIView!
  @IBOutlet weak var locationView: UIView!
  
  @IBOutlet weak var yearMonthLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var weeklabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var itemsLabel: UILabel!
  var model:BookingCompleteModel! {
    didSet {
      let date = model.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss")
      if let dateformates = date?.string(withFormat: "MMM yyyy dd EEE").split(separator: " ") {
        yearMonthLabel.text = dateformates[0] + " " + dateformates[1]
        dayLabel.text = String(dateformates[2])
        weeklabel.text = dateformates[3].uppercased()
      }
      locationLabel.text = model.location_alias_name.isEmpty ? model.location_name : model.location_alias_name
      itemsLabel.text = model.items.reduce("", { $0 + $1.appending("\n")})
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
