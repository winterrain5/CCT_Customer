//
//  NotificationCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/9.
//

import UIKit
import SwipeCellKit
class NotificationCell: SwipeTableViewCell {
  
  @IBOutlet weak var borderView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var timeLabel: UILabel!
  
  var model:NotificationModel! {
    didSet {
      titleLabel.text = model.title
      contentLabel.text = model.content
      timeLabel.text = model.formatDate
      
      if model.isToDay {
        shadowView.alpha = 1
      }else {
        shadowView.alpha = 0.5
      }
      
      if model.isSelected {
        borderView.borderWidth = 2
      }else {
        borderView.borderWidth = 0
      }
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    borderView.borderColor = R.color.theamRed()
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.1)
    shadowView.shadow(cornerRadius: 16, color: light, offset: CGSize(width: 0, height: 2), radius: 8, opacity: 1)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
