//
//  ServiceFormFooterView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/20.
//

import UIKit

class BookingServiceFormFooterView: UIView {

  @IBOutlet weak var footerView: UIView!
  @IBOutlet weak var confirmButton: LoadingButton!
  var confirmHandler:((LoadingButton)->())?
  var syncCalendar:((Bool)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
   setConfirmButtonIsReady(false)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  @IBAction func syncCalendarAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      sender.imageForNormal = R.image.symptom_check_box_select()
    }else {
      sender.imageForNormal = R.image.symptom_check_box_unselect()
    }
    syncCalendar?(sender.isSelected)
  }
  
  @IBAction func confirmAction(_ sender: LoadingButton) {
    confirmHandler?(sender)
  }
  
  @IBAction func helpAction(_ sender: Any) {
    BookingServiceHelpSheetView.show()
  }
  
  func setConfirmButtonIsReady(_ isOk:Bool) {
    confirmButton.titleColorForNormal = .white
    if isOk {
      confirmButton.isEnabled = true
      confirmButton.backgroundColor = R.color.theamRed()
    }else {
      confirmButton.isEnabled = false
      confirmButton.backgroundColor = R.color.grayE0()
    }
  }
}
