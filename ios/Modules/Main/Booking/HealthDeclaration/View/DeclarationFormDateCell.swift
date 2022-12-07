//
//  DeclarationFormDateOfDeliverCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit

class DeclarationFormDateCell: UITableViewCell {
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!

  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var dateBtn: UIButton!
  var model:HealthDeclarationModel? {
    didSet {
      guard let model = model else {
        return
      }
      numLabel.text = model.questionNum
      descLabel.text = model.description_en
      
      if model.formType == .DeliveryDate {
        dateBtn.titleForNormal = model.delivery_date
      }
      if model.formType == .ChildBirthDate {
        dateBtn.titleForNormal = model.child_birth_date
      }
      
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
  @IBAction func selectDateAction(_ sender: Any) {
    
    DatePickerSheetView.show(minimumDate:Date()){ date in
      let dateStr = date.string(withFormat: "yyyy-MM-dd")
      self.dateBtn.titleForNormal = dateStr
      if self.model?.formType == .ChildBirthDate {
        self.model?.child_birth_date = dateStr
      }
      if self.model?.formType == .DeliveryDate {
        self.model?.delivery_date = dateStr
      }
      
    }
  }
  
}
