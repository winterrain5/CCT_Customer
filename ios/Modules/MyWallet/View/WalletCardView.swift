//
//  WalletCardView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

class WalletCardView: UIView {

  @IBOutlet weak var levelLabel: UILabel!
  @IBOutlet weak var moneyLabel: UILabel!
  @IBOutlet weak var expireTitleLabel: UILabel!
  @IBOutlet weak var expireDateLabel: UILabel!
  @IBOutlet weak var cardOwnerTitleLabel: UILabel!
  @IBOutlet weak var cardOwnerNameLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var gradientView: GradientView!
  @IBOutlet weak var progressView: UIProgressView!

  @IBOutlet weak var descRightCons: NSLayoutConstraint!
  var model:UserModel? {
    didSet {
      guard let userModel = model else { return }
      
      // 是否第一次充值 ： 首次购买新充值卡状态; 0没有购买过,1购买充值卡未达银卡,2购买充值卡达到银卡及以上
      let first_recharge_card_status = userModel.first_recharge_card_status.int ?? 0
      // 购买过充值卡用户的消费额度
//      let consumption = userModel.consumption ?? ""
      
      let active_amount = userModel.active_amount.float() ?? 0
      let keep = userModel.keep.string.formatMoney().dolar // 保级金额
      let upgrade = userModel.upgrade.string.formatMoney().dolar// 下一级金额
      let level = userModel.new_recharge_card_level.int ?? 0
      let cardExpireDate = userModel.new_recharge_card_period.date(withFormat: "yyyy-MM-dd")?.string(withFormat: "dd MMM yyyy")
      levelLabel.text = userModel.new_recharge_card_level_text
      descRightCons.constant = 112
      if level == 0 || level == 1 { // basesic
        basicGradient()
        levelLabel.text = "Basic"
        descLabel.textColor = R.color.gray82()
        if first_recharge_card_status == 0 {
          expireTitleLabel.isHidden = true
          expireDateLabel.isHidden = true
          descRightCons.constant = 24
          descLabel.text = "When you buy a recharge card for the first time, you can enjoy benefits. Recharge $500 to upgrade silver card, recharge $1000 to gold card and recharge $2000 to platinum card."
          progressView.setProgress(0, animated: false)
        }else {
          expireTitleLabel.isHidden = false
          expireDateLabel.isHidden = false
          descLabel.text = "You are " + upgrade + " away from getting upgraded to Silver Tier for greater benefits."
          progressView.setProgress((active_amount / 200) * 100, animated: false)
        }
      }
      
      if level == 2 { // silver
        silverGradient()
        levelLabel.text = "Silver"
        descLabel.textColor = R.color.gray82()
        descLabel.text = "You are " + upgrade + " away from getting upgraded to Gold Tier for greater benefits."
        progressView.setProgress((active_amount / 300) * 100, animated: false)
      }
      
      if level == 3 { // gold
        goldGradient()
        levelLabel.text = "Gold"
        descLabel.textColor = R.color.black333()
        descLabel.text = "You are " + upgrade + " away from getting upgraded to Platinum Tier for greater benefits.."
        progressView.setProgress((active_amount / 500) * 100, animated: false)
      }
      
      if level == 4 { // platinum
        platinumGradient()
        levelLabel.text = "Platinum"
        descLabel.textColor = R.color.black333()
        descLabel.text = "Spend or Top up " + keep + " more to maintain Platinum Tier"
        progressView.setProgress((active_amount / 1000) * 100, animated: false)
      }
      
      expireDateLabel.text = cardExpireDate
      layoutIfNeeded()
      
      hideSkeleton()
    }
    
  }
  
  var money:String = "" {
    didSet {
      moneyLabel.text = money
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.1)
    shadowView.shadow(cornerRadius: 16, color: light, offset: CGSize(width: 0, height: 4), radius: 10, opacity: 1)
    gradientView.clipsToBounds = true
    gradientView.cornerRadius = 16
    showSkeleton()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
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
    progressView.progressImage = R.image.wallet_card_progress()
  }
  
  func silverGradient() {
    gradientView.locations = [0,1]
    gradientView.colors = [UIColor(hexString: "#DDDDDD")!,UIColor(hexString: "#F1F1F1")!]
  }
  
  func basicGradient() {
    gradientView.locations = [0,1]
    gradientView.colors = [UIColor(hexString: "#C4D0D5")!,UIColor(hexString: "#D2DBDF")!]
  }
  
  @IBAction func topUpButtonAction(_ sender: Any) {
    
    let vc = WalletTopUpController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
}
