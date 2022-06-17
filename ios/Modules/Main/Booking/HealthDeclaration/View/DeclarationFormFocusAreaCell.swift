//
//  DeclarationFormFocusAreaCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/16.
//

import UIKit

class DeclarationFormFocusAreaCell: UITableViewCell {

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  var isSelect = false
  var updateOptionsHandler:((HealthDeclarationModel)->())?
  var model:HealthDeclarationModel? {
    didSet {
      guard let model = model else {
        return
      }

      descLabel.text = model.description_en
      numLabel.text = model.index < 10 ? "Question 0\(model.index)" : "Question \(model.index)"
      
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  
 
  @IBAction func focusAreaAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      selectStyle(sender)
    }else {
      normalStyle(sender)
    }
  }
  
  func updateSelectStatus(_ sender:UIButton,result:String) {
    
    if result == model?.result { return }
    model?.result = result
    updateOptionsHandler?(model!)
  }
  
  func selectStyle(_ btn:UIButton) {
    btn.backgroundColor = R.color.grayf2()
    btn.setTitleColor(R.color.theamRed(), for: .normal)
    btn.tintColor = R.color.theamRed()
  }
  func normalStyle(_ btn:UIButton) {
    btn.backgroundColor = R.color.white()
    btn.setTitleColor(R.color.grayBD(), for: .normal)
    btn.tintColor = R.color.grayBD()
  }
    
}
