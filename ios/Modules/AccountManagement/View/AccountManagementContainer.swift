//
//  AccountManagementContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit

class AccountManagementContainer: UIView {

  @IBOutlet weak var phoneNumberLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var idNoLabel: UILabel!
  var model:UserModel! {
    didSet {
      phoneNumberLabel.text = "+65 " + (model.phone)
      emailLabel.text = model.email
      
      var cardNo = model.card_number
      if cardNo.count < 5 {
        idNoLabel.text = cardNo
        return
      }
      let startIndex =  cardNo.startIndex
      let endIndex = cardNo.index(startIndex, offsetBy: 4)
      cardNo = cardNo.replacingCharacters(in: startIndex...endIndex, with: "*****")
      idNoLabel.text = cardNo
      
    }
  }
  
  @IBAction func changePhoneNumberAction(_ sender: Any) {
     showVerifySheetView(.EditPhone)
  }
  @IBAction func changeEmailAction(_ sender: Any) {
    showVerifySheetView(.EditEmail)
  }
  @IBAction func idNoLockAction(_ sender: Any) {
    AlertView.show(title: "Locked Information", message: "For security reasons, you will not be able to make changes to your Identification Number.\n\nPlease contact our staff or visit our nearby Chien Chi Tow outlet should you want to make any changes to this information")
  }
  
  @IBAction func changePwdAction(_ sender: Any) {
    showVerifySheetView(.EditPassword)
  }
  
  @IBAction func DeleteAccount(_ sender: Any) {
    showVerifySheetView(.DeleteAccount)
  }
  func showVerifySheetView(_ type:SendVerificaitonCodeType) {
    AccountVerifyPwdSheetView.show(fromView: (UIViewController.getTopVc()?.view)!,type: type)
  }
}
