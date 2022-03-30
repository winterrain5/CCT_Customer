//
//  DataProtectionHeadView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/1.
//

import UIKit

class DataProtectionHeadView: UIView {

    
  @IBOutlet weak var button: UIButton!
  @IBOutlet weak var sectionLabel: UILabel!
  @IBOutlet weak var arrowImageView: UIImageView!
  var selectSectionHandler:((Bool)->())?
  @IBAction func buttonAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    let angle = (sender.isSelected) ? Double.pi : 0
    let anim = CABasicAnimation()
    anim.keyPath = "transform.rotation"
    anim.toValue = angle
    anim.duration = 0.3
    anim.isRemovedOnCompletion = false
    anim.fillMode = CAMediaTimingFillMode.forwards
    arrowImageView?.layer.add(anim, forKey: nil)
    selectSectionHandler?(sender.isSelected)
  }
  func setTitle(_ title:String) {
    sectionLabel.text = title
  }
  func setSelectStatus() {
    buttonAction(button)
  }
  
}
