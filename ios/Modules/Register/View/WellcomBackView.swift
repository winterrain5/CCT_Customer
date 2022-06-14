//
//  WellcomBackView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/13.
//

import UIKit

class WellcomBackView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  @IBAction func goAction(_ sender: Any) {
    
    let vc = InputIDController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
    
  }
  
}
