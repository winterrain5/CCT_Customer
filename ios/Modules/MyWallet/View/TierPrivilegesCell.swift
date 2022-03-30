//
//  TierPrivilegesCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/8.
//

import UIKit

class TierPrivilegesCell: UITableViewCell {
  @IBOutlet weak var tierlabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var gradientView: GradientView!
  @IBOutlet weak var levelLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var privilegesTitleLabel: UILabel!
  @IBOutlet weak var privilegesDescLabel: UILabel!
  @IBOutlet weak var shadowVHCons: NSLayoutConstraint!
  var model:TierListModel! {
    didSet {
      tierlabel.text = model.tierLevel
      descLabel.text = model.tierDesc
      levelLabel.text = model.level
      amountLabel.text = "$" + model.amount
      if !model.privileges.string.isEmpty {
        privilegesDescLabel.attributedText = model.privileges
        privilegesTitleLabel.text = "Your Privileges"
      }else {
        privilegesDescLabel.text = ""
        privilegesTitleLabel.text = ""
      }
      
      if model.id == 1 {
        basicGradient()
      }
      if model.id == 2 {
        silverGradient()
      }
      if model.id == 3 {
        goldGradient()
      }
      if model.id == 4 {
        platinumGradient()
      }
      if model.id == 1 {
        shadowVHCons.constant = 120
        shadowView.borderColor = .white
        shadowView.borderWidth = 1
      }else {
        shadowVHCons.constant = privilegesDescLabel.requiredHeight + 188
        shadowView.borderWidth = 0
      }
      
      layoutIfNeeded()
    }
  }
  @IBOutlet weak var shadowView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.1)
    shadowView.shadow(cornerRadius: 16, color: light, offset: CGSize(width: 0, height: 16), radius: 16, opacity: 1)
    gradientView.cornerRadius = 16
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func goldGradient() {
    gradientView.locations = [0,1]
    gradientView.colors = [UIColor(hexString: "#F4BB4B")!,UIColor(hexString: "#FFEBA4")!]
    
  }
  
  func platinumGradient() {
    
    let layer0 = CAGradientLayer()
    
    layer0.colors = [
      
      UIColor(red: 1, green: 0.873, blue: 0.683, alpha: 1).cgColor,
      
      UIColor(red: 1, green: 0.93, blue: 0.87, alpha: 1).cgColor,
      
      UIColor(red: 1, green: 0.735, blue: 0.425, alpha: 1).cgColor
      
    ]
    
    layer0.locations = [0, 0.5, 1]
    
    layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
    
    layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
    
    layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -1, b: -1, c: 1, d: -3.16, tx: 0.5, ty: 2.58))
    
    layer0.bounds = gradientView.bounds.insetBy(dx: -0.5*gradientView.bounds.size.width, dy: -0.5*gradientView.bounds.size.height)
    
    layer0.position = gradientView.center
    
    
    gradientView.layer.insertSublayer(layer0, at: 0)
  }
  
  func silverGradient() {
    gradientView.locations = [0,1]
    gradientView.colors = [UIColor(hexString: "#DDDDDD")!,UIColor(hexString: "#F1F1F1")!]
  }
  
  func basicGradient() {
    gradientView.locations = [0,1]
    gradientView.colors = [UIColor(hexString: "#C4D0D5")!,UIColor(hexString: "#D2DBDF")!]
  }
  
}
