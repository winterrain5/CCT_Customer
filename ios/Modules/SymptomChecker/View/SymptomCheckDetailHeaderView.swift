//
//  SymptomCheckDetailHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckDetailHeaderView: UIView {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var cornerView: UIView!
  @IBOutlet weak var symptomsLabel: UILabel!
  @IBOutlet weak var titleTopCons: NSLayoutConstraint!
  
  @IBOutlet weak var overviewLabel: UILabel!
  var model:SymptomCheckQ1ResultModel! {
    didSet {
      overviewLabel.text = model.overview_describe
    }
  }
  var result:[[SymptomCheckStepModel]] = []{
    didSet {
      let str1 = result.first?.map({$0.title ?? ""}).joined(separator: " & ") ?? ""
      let str2 = result[2].map({ "-Experiencing at the " + ($0.title ?? "")}).reduce("", { $0 + "\n" + $1}).removingPrefix("\n")
      let str3 = "Recent activity " + (result[1].first?.title ?? "")
      let str = "-\(str1)\n\(str2)\n-\(str3)"
      symptomsLabel.text = str
    }
  }
  var updateCompleteHandler:((CGFloat)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    self.showSkeleton()
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    cornerView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  func configData(_ model:SymptomCheckQ1ResultModel,_ result:[[SymptomCheckStepModel]],_ date:String? = nil) {
    
    self.model = model
    self.result = result
    
    self.hideSkeleton()
    
    self.dateLabel.text = date?.date(withFormat: "yyyy-MM-dd")?.string(withFormat: "dd MMM yyyy,EEE") ?? ""

    titleTopCons.constant = date != nil ? 54 : 32
    
    setNeedsLayout()
    layoutIfNeeded()
   
    let symptomsH = symptomsLabel.requiredHeight
    let overviewH = overviewLabel.requiredHeight
    
    let extraH:CGFloat = date != nil ? 22 : 0
    let totalH = symptomsH + overviewH + 190 + extraH
    self.updateCompleteHandler?(totalH)
    
  }
}
