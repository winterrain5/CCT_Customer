//
//  ShopSelectCouponOrVoucherCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/15.
//

import UIKit

class ShopSelectCouponOrVoucherCell: UITableViewCell {
  
  
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var imgView: UIImageView!
  
  var voucher:WalletVouchersModel! {
    didSet {
      setupData(name: voucher.name, desc: voucher.description, img: "", date: voucher.last_use_date ?? "")
    }
  }
  
  var coupon:WalletCouponsModel! {
    didSet {
      setupData(name: coupon.name, desc: coupon.description, img: coupon.img ?? "", date: coupon.expired_time ?? "")
    }
  }
  
  var useNowHandler:((Codable)->())?
  
  func setupData(name:String?,desc:String?,img:String,date:String) {
    nameLabel.text = name
    descLabel.text = desc
    imgView.yy_setImage(with: img.asURL, options: .setImageWithFadeAnimation)
    let dateStr = date.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM yyyy,EEE") ?? ""
    dateLabel.text = "Expires on \(dateStr)"
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  @IBAction func userNowAction(_ sender: Any) {
    if voucher != nil {
      useNowHandler?(voucher)
    }else {
      useNowHandler?(coupon)
    }
    UIViewController.getTopVc()?.navigationController?.popViewController()
  }
  
}
