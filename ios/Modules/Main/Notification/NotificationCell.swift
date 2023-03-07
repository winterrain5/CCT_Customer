//
//  NotificationCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/5/9.
//

import UIKit
import SwipeCellKit
enum NotificationAcitonType {
  case CheckWallet
  case CheckAppointment
}
class NotificationCell: SwipeTableViewCell {
  
  @IBOutlet weak var borderView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var buttonBottomCons: NSLayoutConstraint!
  
  @IBOutlet weak var buttonHCons: NSLayoutConstraint!
  @IBOutlet weak var button: LoadingButton!
  var notificationAciton:((NotificationAcitonType,NotificationModel,LoadingButton)->())?
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
      
      let bookingId = model.booking_id.double() ?? 0
      let friendId = model.friend_id.double() ?? 0
      var buttonHidden = false
      var buttonBottom:CGFloat = 16
      var buttonH:CGFloat = 40
      var buttonText = ""
      if bookingId > 0 {
        buttonText = "Check Appointment"
      }else if friendId > 0 {
        buttonText = "Check Wallet"
      } else {
        buttonHidden = true
        buttonBottom = 0
        buttonH = 0
        buttonText = ""
      }
      buttonBottomCons.constant = buttonBottom
      buttonHCons.constant = buttonH
      button.isHidden = buttonHidden
      button.titleForNormal = buttonText
      setNeedsLayout()
      layoutIfNeeded()
      
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    borderView.borderColor = R.color.theamRed()
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.1)
    shadowView.shadow(cornerRadius: 16, color: light, offset: CGSize(width: 0, height: 2), radius: 8, opacity: 1)
    shadowView.isUserInteractionEnabled = true
   
    button.rx.tap.subscribe(onNext:{ [weak self] in
      guard let `self` = self else { return }
      let bookingId = self.model.booking_id.double() ?? 0
      print(self.model.description)
      if bookingId > 0 {
        self.notificationAciton?(.CheckAppointment,self.model,self.button)
      } else {
        self.notificationAciton?(.CheckWallet,self.model,self.button)
      }
    }).disposed(by: rx.disposeBag)
  
    
  }
  

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
