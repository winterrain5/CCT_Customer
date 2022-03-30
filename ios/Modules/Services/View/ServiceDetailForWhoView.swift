//
//  ServiceDetailForWhoView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit

class ServiceDetailForWhoView: UIView {

  @IBOutlet weak var forWhoLabel: UILabel!
  
  var updateHandler:((CGFloat)->())?
  var brifeModel:ServiceBriefData? {
    didSet {
      forWhoLabel.text = brifeModel?.for_what
      
      let h = forWhoLabel.requiredHeight + 134
      updateHandler?(h)
    }
  }

}
