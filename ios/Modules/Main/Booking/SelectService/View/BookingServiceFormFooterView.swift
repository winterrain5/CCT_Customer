//
//  ServiceFormFooterView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/20.
//

import UIKit

class BookingServiceFormFooterView: UIView {
  
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var footerView: UIView!
  @IBOutlet weak var confirmButton: LoadingButton!
  @IBOutlet weak var SmptomsLabel: UILabel!
  @IBOutlet weak var lastActivityLabel: UILabel!
  @IBOutlet weak var areaOfPainLabel: UILabel!
  var confirmHandler:((LoadingButton)->())?
  var heightUpdatedHandler:((CGFloat)->())?
  var syncCalendar:((Bool)->())?
  var result:[[SymptomCheckStepModel]] = [] {
    didSet {
      footerView.isHidden = result.isEmpty
      
      if result.isEmpty { return }
      let symptoms = result.first?.map({$0.title ?? ""}).reduce("", { $0 + "\n" + $1}).removingPrefix("\n")
      let lastActivity = result[1].first?.title ?? ""
      let area = result[2].map({$0.title ?? ""}).reduce("", { $0 + "\n" + $1}).removingPrefix("\n")
      
      SmptomsLabel.text = symptoms
      lastActivityLabel.text = lastActivity
      areaOfPainLabel.text = area
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    self.clipsToBounds = true
    setConfirmButtonIsReady(false)
    infoView.addLightShadow(by: 16)
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
