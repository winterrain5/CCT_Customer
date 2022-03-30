//
//  TCApplyPrivilegesSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/16.
//

import UIKit

@objcMembers
class TCApplyPrivilegesSheetView: UIView {

  private var scrollView = UIScrollView()
  private var titleLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextDemiBold,24)
    label.text = "T&C and Privileges"
  }
  private var contentLabel = UILabel().then { label in
    label.textColor = .black
    label.font = UIFont(.AvenirNextRegular,16)
    label.numberOfLines = 0
    label.text = "You can invite your friends by sending them your unique referral link provided by this feature in the Chien Chi Tow app via email, SMS, WhatsApp or other messaging platforms.\n\nYour friends must use the link you send them to install the app and sign-up to receive their $10.00 CCT credit, which will be automatically added to their app wallet.\n\nWhen your friend successfully signs-up with us, you too will receive $10.00 CCT credit that will be automatically added to your app wallet.\n\nCredits can be utilised without minimum spend restrictions.\n\nCredits cannot be used in conjunction with any other offers or vouchers.\n\nCredits will expire 31 days after they are issued to you.\n\nYou will receive credits for up to 10 people you invite and who successfully utilises their credits.\n\nYou can view all credits you’ve accumulated in \"My Wallet\"\n\nChien Chi Tow reserves the right to update these terms and conditions with effect for the future at any time."
   
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    addSubview(scrollView)
    addSubview(titleLabel)
    scrollView.addSubview(contentLabel)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(32)
    }
    scrollView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(100)
    }
    contentLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(32)
      make.top.equalToSuperview()
      make.width.equalTo(kScreenWidth - 64)
    }
    
    scrollView.contentSize = CGSize(width: kScreenWidth, height: contentLabel.sizeThatFits(CGSize(width: kScreenWidth - 64, height: .infinity)).height)
  }
  
  static func show() {
    let view = TCApplyPrivilegesSheetView()
    let size = CGSize(width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    EntryKit.display(view: view, size: size, style: .sheet)
  }
}
