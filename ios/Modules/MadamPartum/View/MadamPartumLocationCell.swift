//
//  MadamPartumLocationCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/26.
//

import UIKit

class MadamPartumLocationCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var oparatingLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var phoneButton: UIButton!
  @IBOutlet weak var whatsappButton: UIButton!
  
  var model:MadamPartumLocationModel! {
    didSet {
      nameLabel.text = model.name
      locationLabel.text = model.address
      
      let mTf = "Mon to Fri - \(model.mon_fri_start ?? "")am to \(model.mon_fri_end ?? "")pm"
      let ssp = "Sat,Sun,PH - \(model.sat_sun_start ?? "")am to \(model.sat_sun_end ?? "")"
      oparatingLabel.text = mTf + "\n" + ssp
      
      phoneButton.titleForNormal = model.phone
      whatsappButton.titleForNormal = model.whatapp
    }
  }
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  @IBAction func leftTelButtonAction(_ sender: Any) {
    let phone = self.model.phone ?? ""
    CallUtil.callPhone(phone)
   
  }
  
  @IBAction func rightButtonAction(_ sender: Any) {
    let phone = self.model.whatapp ?? ""
    CallUtil.callWhatsapp(phone)
   
  }
  
  func callPhone(with phone:String) {
    guard let url =  URL(string: phone) else {
      Toast.showError(withStatus: "wrong number")
      return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}
