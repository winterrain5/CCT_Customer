//
//  WalletTermsConditionsSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/9.
//

import UIKit

class WalletTermsConditionsSheetView: UIView {

  private var scrollView = UIScrollView()
  private var titleLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextDemiBold,24)
    label.text = "Terms & Conditions"
  }
  private var contentLabel = UILabel().then { label in
    label.textColor = .black
    label.font = UIFont(.AvenirNextRegular,16)
    label.numberOfLines = 0
    label.text = "For purchase of treatment using CCT Wallet, member will receive FOC consultation with physician.\n\nRedemption of sessions are based on ala carte pricing.\n\nCredits can be used for Chien Chi Tow / Madam Partum label products, pills and medication.\n\nCredit value is inclusive of GST amount\n\nBonus value cannot be used for GST or tax declaration.\n\nPrivilege tiers are tagged to current wallet.\n\nCredits are valid for 1 year from the date of purchase.\n\nCustomer can hold 1 CCT Wallet at any one time\n\nChien Chi Tow will not be held responsible for the misuse of credits due to 1) loss of device, 2) utilisation of credits by nominated user. Members should report to Chien Chi Tow immediately to suspend account from further misuse."
   
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
    let view = WalletTermsConditionsSheetView()
    let size = CGSize(width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    EntryKit.display(view: view, size: size, style: .sheet)
  }

}
