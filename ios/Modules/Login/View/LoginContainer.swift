//
//  LoginContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/28.
//

import UIKit

class LoginContainer: UIView {

  @IBOutlet weak var topRoundVTopCons: NSLayoutConstraint!
  @IBOutlet weak var topRoundVHCons: NSLayoutConstraint!
  @IBOutlet weak var topRoundVWCons: NSLayoutConstraint!
  @IBOutlet weak var topRoundView: UIView!
  
  @IBOutlet weak var top3Cons: NSLayoutConstraint!
  @IBOutlet weak var top2Cons: NSLayoutConstraint!
  @IBOutlet weak var top1Cons: NSLayoutConstraint!
  
  @IBOutlet weak var bottom1Cons: NSLayoutConstraint!
  override func awakeFromNib() {
    super.awakeFromNib()
    
    if kScreenHeight > 667 {
      topRoundVHCons.constant = 538~
      topRoundVWCons.constant = 538~
      topRoundVTopCons.constant = -206~
      topRoundView.cornerRadius = 269~
      top1Cons.constant = 44
      top2Cons.constant = 32
      top3Cons.constant = 46
      bottom1Cons.constant = 95
    }else {
      let scale = kScreenHeight / 812
      topRoundVHCons.constant = 538~ * scale
      topRoundVWCons.constant = 538~ * scale
      topRoundVTopCons.constant = -206~ * scale
      topRoundView.cornerRadius = 269~ * scale
      top1Cons.constant = 44 * scale
      top2Cons.constant = 32 * scale
      top3Cons.constant = 46 * scale
      bottom1Cons.constant = 95 * scale
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  @IBAction func signupAction(_ sender: Any) {
    
    let vc = InputResideController()
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)

  }
  
  @IBAction func loginAction(_ sender: Any) {
    let vc = EnterAccountController()
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
  @IBAction func checkInAction(_ sender: Any) {
    
  }
}
