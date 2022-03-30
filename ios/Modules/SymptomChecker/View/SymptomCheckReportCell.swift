//
//  SymptomCheckReportCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/14.
//

import UIKit

class SymptomCheckReportCell: UITableViewCell {

  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var datelabel: UILabel!
  @IBOutlet weak var symptomsQasLabel: UILabel!
  @IBOutlet weak var painAreaLabel: UILabel!
  var deleteHandler:((SymptomCheckReportModel)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addLightShadow(by: 16)
  }
  var model:SymptomCheckReportModel! {
    didSet {
      let date = model.fill_date?.date(withFormat: "yyyy-MM-dd")?.string(withFormat: "dd MMM yyyy,EEE")
      datelabel.text = date
      
      let str1 = model.symptoms_qas?.map({$0.title ?? ""}).joined(separator: " & ") ?? ""
      let str2 = model.pain_areas?.map({ "Experiencing at the " + ($0.title ?? "")}).reduce("", { $0 + "\n" + $1}).removingPrefix("\n")
      let str3 = "Recent activity " + (model.best_describes_qa_title ?? "")
      let str = "\(str2 ?? "")\n\(str3)"
      symptomsQasLabel.text = str1
      painAreaLabel.text = str
    }
  }
  @IBAction func deleteAction(_ sender: Any) {
    deleteHandler?(model)
  }
  
}
