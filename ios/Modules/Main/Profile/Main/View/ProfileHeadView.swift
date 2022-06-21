//
//  ProfileHeadView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/29.
//

import UIKit

class ProfileHeadView: UIView {

  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var levelLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var pointsLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var gradientView: GradientView!
  
  @IBOutlet weak var infoContentView: UIView!
  @IBOutlet weak var bottomInfoView: UIView!
  var money:String = "" {
    didSet {
      amountLabel.text = money
    }
  }
  var model:UserModel! {
    didSet {
      hideSkeleton()
      
      nameLabel.text = model.first_name + " " + model.last_name
      
      let level = model.new_recharge_card_level.int ?? 0
      
      if level == 0 || level == 1 { // basesic
        basicGradient()
        levelLabel.text = "Basic"
        
      }
      
      if level == 2 { // silver
        silverGradient()
        levelLabel.text = "Silver"
       
      }
      
      if level == 3 { // gold
        goldGradient()
        levelLabel.text = "Gold"
        
      }
      
      if level == 4 { // platinum
        platinumGradient()
        levelLabel.text = "Platinum"
        
      }
      
      pointsLabel.text = model.points.int.string
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.1)
    shadowView.shadow(cornerRadius: 16, color: light, offset: CGSize(width: 0, height: 4), radius: 10, opacity: 1)
    gradientView.clipsToBounds = true
    gradientView.cornerRadius = 16
    
    infoContentView.rx
      .tapGesture()
      .when(.recognized)
      .subscribe(onNext: { _ in
        let vc = MyWalletController()
        UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
      })
      .disposed(by: rx.disposeBag)

    
    showSkeleton()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    bottomInfoView.corner(byRoundingCorners: [.bottomLeft,.bottomRight], radii: 16)
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
  
  @IBAction func editAction(_ sender: Any) {
    
    let vc = EditProfileViewController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
    
  }
}
