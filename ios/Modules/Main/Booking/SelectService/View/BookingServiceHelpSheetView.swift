//
//  BookingServiceHelpSheetView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/24.
//

import UIKit

class BookingServiceHelpSheetView: UIView {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = .white
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  @IBAction func contactAction(_ sender: Any) {
    
    let vc = ContactUsViewController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, animated: true)
    
    EntryKit.dismiss()
  }
  
  static func show() {
    let view = BookingServiceHelpSheetView.loadViewFromNib()
    let size = CGSize(width: kScreenWidth, height: 382 + kBottomsafeAreaMargin)
    EntryKit.displayView(asSheet: view, size: size)
  }
}
