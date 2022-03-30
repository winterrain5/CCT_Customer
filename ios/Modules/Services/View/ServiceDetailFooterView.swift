//
//  ServiceDetailFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit

class ServiceDetailFooterView: UIView {

  @IBOutlet weak var planLabel: UILabel!
  var updateHandler:((CGFloat)->())?
  var plan:SymptomCheckPlanModel? {
    didSet {
      planLabel.text = plan?.overview_description
      
      let h = planLabel.requiredHeight + 210
      updateHandler?(h)
    }
  }

  @IBAction func planButtonAction(_ sender: Any) {
    let vc = SymptomCheckTreamentPlanWebController()
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
}
