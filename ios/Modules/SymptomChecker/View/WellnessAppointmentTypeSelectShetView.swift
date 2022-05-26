//
//  WellnessAppointmentTypeSelectShetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit

class WellnessAppointmentTypeSelectShetView: UIView {

  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  @IBAction func selectDateTimeButtonAction(_ sender: Any) {
    EntryKit.dismiss {
      let vc = BookingAppointmentController(type: .DateTime)
      UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
    }
  }
  

  @IBAction func selectATherapistButtonAction(_ sender: Any) {
    EntryKit.dismiss {
      let vc = BookingAppointmentController(type: .Therapist)
      UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
    }
    
  }
  
  static func show() {
    let view = WellnessAppointmentTypeSelectShetView.loadViewFromNib()
    let size = CGSize(width: kScreenWidth, height: 432)
    EntryKit.display(view: view, size: size, style: .sheet)
  }
}
