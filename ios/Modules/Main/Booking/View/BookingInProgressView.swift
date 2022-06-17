//
//  BookingInProgressView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/17.
//

import UIKit

class BookingInProgressView: UIView {

  @IBOutlet weak var queueNoLabel: UILabel!
  @IBOutlet weak var employeeNameLabel: UILabel!
  @IBOutlet weak var employeeView: UIView!
  @IBOutlet weak var shadowV1TopCons: NSLayoutConstraint!
  @IBOutlet weak var shaowV1HCons: NSLayoutConstraint!
  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var remarkLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var shadowView1: UIView!
  @IBOutlet weak var shadowView3: UIView!
  @IBOutlet weak var whatsappLabel: UILabel!
  @IBOutlet weak var shadowView2: UIView!

  var today:BookingTodayModel? {
    didSet {
      guard let today = today else {
        return
      }
      nameLabel.text = today.alias_name
      if let date = today.therapy_start_date.date(withFormat: "yyyy-MM-dd HH:mm:ss") {
        dateLabel.text = date.string(withFormat: "dd MMM yyyy,EEE - ").appending(date.timeString(ofStyle: .short))
      }
      if today.wellness_or_treatment == "2" {
        shadowView2.isHidden = false
        shadowV1TopCons.constant = 120
        employeeView.isHidden = true
        employeeNameLabel.text = today.staff_name
        shaowV1HCons.constant = 80
      }else {
        shadowView2.isHidden = true
        shadowV1TopCons.constant = 24
        employeeView.isHidden = today.staff_is_random == "1"
        employeeNameLabel.text = today.staff_name
        shaowV1HCons.constant = today.staff_is_random == "1" ? 80 : 108
      }
      queueNoLabel.text = today.queue_no
      
      layoutIfNeeded()
    }
  }
  
  var company:CompanyModel! {
    didSet {
      phoneLabel.text = company.phone
      whatsappLabel.text = company.whatapp
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView1.addLightShadow(by: 16)
    shadowView2.addLightShadow(by: 16)
    shadowView3.addLightShadow(by: 16)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topRight,.topLeft], radii: 16)
  }
  
  @IBAction func phoneAction(_ sender: Any) {
    CallUtil.callPhone(company.phone)
  }
  
  @IBAction func whatsappAction(_ sender: Any) {
    CallUtil.callWhatsapp(company.whatapp)
  }

}
