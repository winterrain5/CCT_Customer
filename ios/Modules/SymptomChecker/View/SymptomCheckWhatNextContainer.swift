//
//  SymptomCheckWhatNext.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/13.
//

import UIKit

class SymptomCheckWhatNextContainer: UIView {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var saveButton: UIButton!

  var bookAppointmentHandler:(()->())?
  var saveReportHandler:((Bool)->())?
  var emailMeHandler:(()->())?
  var backHandler:(()->())?
  var doneHandler:(()->())?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    saveButton.isSelected = true
    titleLabel.textAlignment = .center
  }
  @IBAction func bookAppointmentButtonAction(_ sender: Any) {
    bookAppointmentHandler?()
  }
  @IBAction func saveReportButtonAction(_ sender: UIButton) {
    saveButton.isSelected.toggle()
    if saveButton.isSelected {
      saveButton.borderColor = .clear
      saveButton.imageForNormal = R.image.symptom_check_box_select()
    }else {
      saveButton.borderWidth = 1
      saveButton.borderColor = UIColor(hexString: "777777")
      saveButton.imageForNormal = R.image.symptom_check_box_unselect()
    }
    saveReportHandler?(saveButton.isSelected)
  }
  
  @IBAction func emailMeButtonAction(_ sender: Any) {
    emailMeHandler?()
  }
  @IBAction func backButtonAction(_ sender: Any) {
    backHandler?()
  }
  @IBAction func doneButtonAction(_ sender: Any) {
    doneHandler?()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topRight,.topLeft], radii: 16)
  }
}
