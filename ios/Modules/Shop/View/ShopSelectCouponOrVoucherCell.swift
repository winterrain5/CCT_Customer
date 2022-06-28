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
  

  @IBOutlet weak var selectButton: UIButton!
  var voucher:WalletVouchersModel! {
    didSet {
      setupData(name: voucher.name, desc: voucher.desc, img: "", date: voucher.last_use_date ?? "")
      if voucher.isSelected {
        selectButton.titleForNormal = "Cancel Use"
      }else {
        selectButton.titleForNormal = "Use Now"
      }
    }
  }
  
  var coupon:WalletCouponsModel! {
    didSet {
      setupData(name: coupon.name, desc: coupon.desc, img: coupon.img ?? "", date: coupon.expired_time ?? "")
      if coupon.isSelected {
        selectButton.titleForNormal = "Cancel Use"
      }else {
        selectButton.titleForNormal = "Use Now"
      }
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
      voucher.isSelected.toggle()
      useNowHandler?(voucher)
    }else {
      coupon.isSelected.toggle()
      useNowHandler?(coupon)
    }
    UIViewController.getTopVc()?.navigationController?.popViewController()
  }
  
}
