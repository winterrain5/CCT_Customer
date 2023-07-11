//
//  CardUserDetailHeadView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/9.
//

import UIKit

class CardUserDetailHeadView: UIView {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var transactionLimitLabel: UILabel!
  var cardUserModel:CardOwnerModel? {
    didSet {
      if cardUserModel?.status == "0" {
        nameLabel.text = cardUserModel?.owner_remark
      } else {
        nameLabel.text = (cardUserModel?.first_name ?? "") + " " + (cardUserModel?.last_name ?? "")
      }
      phoneLabel.text = cardUserModel?.mobile
      if (cardUserModel?.trans_limit?.float() ?? 0) < 0 {
        transactionLimitLabel.text = "no limit limit per transaction"
      }else {
        transactionLimitLabel.text = "$\(cardUserModel?.trans_limit ?? "") limit per transaction"
      }
     
    }
  }
    
   @IBAction func deleteButtonAction(_ sender: Any) {
    
     AlertView.show(title: "Are you sure you want to remove this user?", message: "", leftButtonTitle: "Cancel", rightButtonTitle: "Confirm", messageAlignment: .center) {
       
     } rightHandler: {
       let params = SOAPParams(action: .Voucher, path: .deleteCardFriend)
       params.set(key: "id", value: self.cardUserModel?.id ?? "")
       
       let log = SOAPDictionary()
       log.set(key: "create_uid", value: Defaults.shared.get(for: .userModel)?.user_id ?? "")
       params.set(key: "logData", value: log.result, type: .map(1))
       
       Toast.showLoading()
       NetworkManager().request(params: params) { data in
         
         self.deleteUserFromWalletNotification()
         
       } errorHandler: { e in
         UIViewController.getTopVc()?.navigationController?.popViewController()
       }
     } dismissHandler: {
       
     }

    

   }
  
  func deleteUserFromWalletNotification() {

    let params = SOAPParams(action: .Notifications, path: .deleteUserFromWallet)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "friendId", value: cardUserModel?.friend_id ?? "")
    

    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      UIViewController.getTopVc()?.navigationController?.popViewController()
    } errorHandler: { e in
      UIViewController.getTopVc()?.navigationController?.popViewController()
    }
  }
  
  @IBAction func transactionLimitButtonAction(_ sender: Any) {
    if let model = cardUserModel {
      SetTransactionLimitSheetView.show(cardUserModel: model) { model in
        self.cardUserModel = model
      }
    }
    
  }
  
}
