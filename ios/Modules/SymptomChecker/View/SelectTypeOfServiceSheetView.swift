//
//  SelectTypeOfServiceSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/17.
//

import UIKit

class SelectTypeOfServiceSheetView: UIView {
  var treatmentHandler:(()->())?
  var wellnessHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func treamentButtonAction(_ sender: Any) {
    EntryKit.dismiss {
      AlertView.show(title: "Share more about your condition?", message: "", leftButtonTitle: "Skip", rightButtonTitle: "Yes") {
        
        let vc = RNBridgeViewController(RNPageName: "BookAppointmentActivity", RNProperty: ["select_type":"0"])
        UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
        
      } rightHandler: {
       
//        NotificationCenter.default.post(name: .nativeNotification, object: "TellUsCondition1Activity" ,userInfo: ["type":"OpenRNPage"])
        let vc = RNBridgeViewController(RNPageName: "TellUsCondition1Activity", RNProperty: [:])
        UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
//
      }
    }
  }
  

  @IBAction func wellnessButtonAction(_ sender: Any) {
    EntryKit.dismiss {
      WellnessAppointmentTypeSelectShetView.show()
    }
  }
  
  static func show() {
    let view = SelectTypeOfServiceSheetView.loadViewFromNib()
    let size = CGSize(width: kScreenWidth, height: 432)
    EntryKit.display(view: view, size: size, style: .sheet)
  }
}
