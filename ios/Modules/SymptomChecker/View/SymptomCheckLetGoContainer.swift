//
//  SymptomCheckLetGoContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckLetGoContainer: UIView {

  @IBOutlet weak var topCons: NSLayoutConstraint!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var textLabel: UILabel!
  var goHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    topCons.constant = kNavBarHeight
    setNeedsLayout()
    
    textLabel.textAlignment = .center
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  @IBAction func buttonAction(_ sender: Any) {
    goHandler?()
  }
}
