//
//  NotificationApproveWalletCell.swift
//  CCTIOS
//
//  Created by Derrick on 2023/7/11.
//

import UIKit

import SwipeCellKit
class NotificationApproveWalletCell: SwipeTableViewCell {
  
  @IBOutlet weak var borderView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var approveContainer: UIView!
  @IBOutlet weak var rejectButton: UIButton!
  @IBOutlet weak var approveButton: UIButton!
 
  @IBOutlet weak var approveHCons: NSLayoutConstraint!
  @IBOutlet weak var approveBottomCons: NSLayoutConstraint!
  
  @IBOutlet weak var readStatusView: UIView!
  var approveHandler:((NotificationModel,IndexPath)->())?
  var rejectHandler:((NotificationModel,IndexPath)->())?
  var indexPath: IndexPath!
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
      
      readStatusView.isHidden = model.is_read == "1"
      
      var approveBottom:CGFloat = 16
      var approveH:CGFloat = 40
      if model.auth_status == "0" && model.owner_id != "0" {
        approveContainer.isHidden = false
      } else {
        approveContainer.isHidden = true
        approveBottom = 0
        approveH = 0
      }
      
      approveHCons.constant = approveH
      approveBottomCons.constant = approveBottom
      
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
   
    approveButton.rx.tap.subscribe(onNext:{ [weak self] in
      guard let `self` = self else { return }
      self.approveHandler?(self.model,self.indexPath)
    }).disposed(by: rx.disposeBag)
    
    rejectButton.rx.tap.subscribe(onNext:{ [weak self] in
      guard let `self` = self else { return }
      self.rejectHandler?(self.model,self.indexPath)
    }).disposed(by: rx.disposeBag)
  }
  

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
