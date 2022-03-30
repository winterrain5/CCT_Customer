//
//  SymptomCheckBeginContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckBeginContainer: UIView {

  @IBOutlet weak var descLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    descLabel.textAlignment = .center
  }
  @IBAction func beginButtonAction(_ sender: Any) {
    let vc = SymptomCheckNextController()
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
  @IBAction func viewReportButtonAction(_ sender: Any) {
    SymptomCheckReportListView.show()
  }


}
