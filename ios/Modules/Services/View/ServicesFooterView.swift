//
//  ServiceFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import UIKit

enum ServicesCategory:Int {
  case All
  case Treatment
  case Wellness
  
  var category:String {
    switch self {
    case .All:
      return ""
    case .Treatment:
      return "2"
    case .Wellness:
      return "1,3"
    }
  }
}

class ServicesFooterView: UICollectionReusableView {


  @IBOutlet weak var allButton: UIButton!
  @IBOutlet weak var treamentButton: UIButton!
  @IBOutlet weak var wellnessButton: UIButton!
  
  var selectedButton:UIButton!
  var segmentDidClickHandler:((ServicesCategory)->())?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    allButton.isSelected = true
    selectedStyle(allButton)
    selectedButton = allButton
    
  }
  
  @IBAction func segmentButtonAction(_ sender: UIButton) {
    
    selectedButton.isSelected = false
    sender.isSelected = true
    if sender.isSelected {
      selectedStyle(sender)
      unselectedStyle(selectedButton)
      segmentDidClickHandler?(ServicesCategory(rawValue: sender.tag)!)
    }
    selectedButton = sender
  }
  
  func selectedStyle(_ sender:UIButton) {
    sender.backgroundColor = UIColor(hexString: "#C44729")
    sender.titleLabel?.font = UIFont(name: .AvenirNextBold, size: 14)
    sender.titleColorForNormal = .white
  }
  
  func unselectedStyle(_ sender:UIButton) {
    sender.backgroundColor = UIColor(hexString: "#f2f2f2")
    sender.titleLabel?.font = UIFont(name:.AvenirNextRegular,size: 14)
    sender.titleColorForNormal = .black
  }

}
