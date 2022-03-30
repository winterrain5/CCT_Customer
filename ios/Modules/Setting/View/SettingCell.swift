//
//  SettingCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/28.
//

import UIKit

class SettingCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var switchControl: UISwitch!
  @IBOutlet weak var arrowImageView: UIImageView!
  var switchHandler:((SettingModel)->())?
  var model:SettingModel! {
    didSet {
      titleLabel.text =  model.title
      descLabel.text = model.descption
      switchControl.isHidden = !model.isSwitch
      arrowImageView.isHidden = model.isSwitch
      switchControl.isOn = model.isOn
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    switchControl.transform = CGAffineTransform.init(scaleX: 0.6, y: 0.6)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    
  }
  @IBAction func switchValueChangeAction(_ sender: Any) {

    model.isOn.toggle()
    switchHandler?(model)
  }
  
}
