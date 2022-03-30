//
//  SymptomCheckPlanHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/17.
//

import UIKit

class SymptomCheckPlanHeaderView: UIView {

  @IBOutlet weak var cornerView: UIView!
  @IBOutlet weak var overviewDescLabel: UILabel!
  @IBOutlet weak var partOneDescLabel: UILabel!
  @IBOutlet weak var partOnePriceLabel: UILabel!
  @IBOutlet weak var partTwoTitleLabel: UILabel!
  @IBOutlet weak var partTwodescLabel: UILabel!
  var updateComplete:((CGFloat)->())?
  var model:SymptomCheckPlanModel? {
    didSet {
      guard let model = model else {
        return
      }
      
      overviewDescLabel.text = model.overview_description
      partOneDescLabel.text = model.part_one_description
      partOnePriceLabel.text = "$\(model.part_one_retail_price ?? "")/Session"
      partTwoTitleLabel.text = model.part_two_title
      partTwodescLabel.text = model.part_two_description
      
      self.hideSkeleton()
      
      // 440
      
      let totalH = overviewDescLabel.requiredHeight + partOneDescLabel.requiredHeight + partTwoTitleLabel.requiredHeight + partTwodescLabel.requiredHeight + 440.cgFloat
      updateComplete?(totalH)
      
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.showSkeleton()
    backgroundColor = R.color.theamBlue()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    cornerView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  

}
