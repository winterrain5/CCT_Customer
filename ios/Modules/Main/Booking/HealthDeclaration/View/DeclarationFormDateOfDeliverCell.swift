//
//  DeclarationFormDateOfDeliverCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit

class DeclarationFormDateOfDeliverCell: UITableViewCell {
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!

  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var dateBtn: UIButton!
  var model:HealthDeclarationModel? {
    didSet {
      guard let model = model else {
        return
      }
      numLabel.text = model.index < 10 ? "Question 0\(model.index)" : "Question \(model.index)"
      descLabel.text = model.description_en
      if model.delivery_date.isEmpty {
        return
      }
      dateBtn.titleForNormal = model.delivery_date
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
      self.model?.delivery_date = dateStr
    }
  }
  
}
