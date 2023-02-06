//
//  ContactUsListCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit
import CoreLocation

class ContactUsListCell: UITableViewCell {
  
  @IBOutlet weak var shaodwView: UIView!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var mfTimeLabel: UILabel!
  @IBOutlet weak var sspTimeLabel: UILabel!
  @IBOutlet weak var phoneButton: UIButton!
  @IBOutlet weak var whatsappButton: UIButton!
  @IBOutlet weak var arrowImageView: UIImageView!
  @IBOutlet weak var footerInfoView: UIView!
  
  var model:ContactUsModel! {
    didSet {
      locationLabel.text = model.alias_name
      addressLabel.text = model.address
      
      
      let mfs = (model.app_work_start?.removingSuffix(":00") ?? "") + "AM"
      let mfe = (model.app_work_end?.removingSuffix(":00") ?? "") + "PM"
      mfTimeLabel.text = " / " + mfs + " - " + mfe
      
      let ssps = (model.app_rest_start?.removingSuffix(":00") ?? "") + "AM"
      let sspe = (model.app_rest_end?.removingSuffix(":00") ?? "") + "PM"
      sspTimeLabel.text = " / " + ssps + " - " + sspe
      
      phoneButton.titleForNormal = " " + (model.phone ?? "")
      whatsappButton.titleForNormal = " " + (model.whatapp ?? "")
      
      let rotatedImage = R.image.question_help_arrow_down()?.yy_imageByRotate180()
      arrowImageView.image = model.isExpend! ? rotatedImage : R.image.question_help_arrow_down()
      
      footerInfoView.isHidden = !(model.isExpend!)
      
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.1)
    shaodwView.shadow(cornerRadius: 16, color: light, offset: CGSize(width: 0, height: 10), radius: 10, opacity: 1)
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @objc func addressTapAction() {
    
    
    

  }
  
  
  
  @IBAction func phoneButtonAction(_ sender: Any) {
    AlertView.show(title:  "Do you want to call \(model.phone ?? "")?", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Sure", messageAlignment: .center, leftHandler: nil, rightHandler: {
      let phone = "tel://\(self.model.phone ?? "")"
      self.callPhone(with: phone)
    }, dismissHandler: nil)
  }
  @IBAction func whatsappButtonAction(_ sender: Any) {
    
    AlertView.show(title: "Do you want to chat with \(model.whatapp ?? "")?", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Sure", messageAlignment: .center, leftHandler: nil, rightHandler: {
      let phone = "https://api.whatsapp.com/send?phone=65\(self.model.whatapp ?? "")"
      self.callPhone(with: phone)
    }, dismissHandler: nil)
  }
  
  @IBAction func addressTapAction(_ sender: Any) {
    let latitude = model.latitude ?? ""
    let longitude = model.longitude ?? ""
    let address = model.address ?? ""
   
   
    if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
      guard let url = "https://maps.google.com/?q=\(address.urlEncoded)&center=\(latitude),\(longitude)&zoom=14".url else {
        Toast.showError(withStatus: "Can't use googlemap")
        return
      }
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
      Toast.showError(withStatus: "Can't use googlemap")
    }
  }
  
  func callPhone(with phone:String) {
    guard let url =  URL(string: phone) else {
      Toast.showError(withStatus: "wrong number")
      return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
 
}
