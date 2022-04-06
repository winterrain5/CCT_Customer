//
//  ReferFriendContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/16.
//

import UIKit

class ReferFriendContainer: UIView {
  
  var referCode:String = ""

  @IBOutlet weak var referCodeLabel: UILabel!
  @IBOutlet weak var cornerView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    if let model = Defaults.shared.get(for: .userModel) {
      self.referCodeLabel.text = model.referral_code
      self.referCode = model.referral_code ?? ""
    }else {
      let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeByCodable(UserModel.self, from: data) {
          self.referCodeLabel.text = model.referral_code
          self.referCode = model.referral_code ?? ""
        }else {
          Toast.showError(withStatus: "Decode UserModel Failed")
        }
      } errorHandler: { e in
        
      }
    }
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    cornerView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  @IBAction func copyReferCodeButtonAction(_ sender: Any) {
    if referCode.isEmpty {
      Toast.showSuccess(withStatus: "Copy Failed")
      return
    }
    UIPasteboard.general.string = referCode
    Toast.showSuccess(withStatus: "Copy Success")
  }
 
  @IBAction func tcApplyButtonAction(_ sender: Any) {
    let view = TCApplyPrivilegesSheetView()
    let size = CGSize(width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    EntryKit.display(view: view, size: size, style: .sheet)
  }
  
  @IBAction func whatsappButtonAction(_ sender: Any) {
    ShareTool.share(to: .WHATSAPP,  shareMessage())
  }
  
  @IBAction func telegramButtonAction(_ sender: Any) {
    ShareTool.share(to: .TELEGRAM,  shareMessage())
  }
  
  @IBAction func messageButtonAction(_ sender: Any) {
    ShareTool.share(to: .SMS, shareMessage())
  }
  
  @IBAction func emailButtonAction(_ sender: Any) {
    ShareTool.share(to: .EMAIL, shareMessage())
  }
  
  func shareMessage() -> String {
    let userModel = Defaults.shared.get(for: .userModel)
    let name = (userModel?.first_name ?? "") + " " + (userModel?.last_name ?? "")
    var string = ""
    string += name
    string += " invites you to download the Chien Chi Tow App. Use the unique invitation code during sign up to receive $10 CCT eWallet credits!\n"
    string += "Invite Code: \(referCode) "
    return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
  }
  
  
  @IBAction func otherShareButtonAction(_ sender: Any) {
    
    let shareItems:Array = [shareMessage().urlDecoded] as [Any]
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [.postToWeibo,  .addToReadingList, .postToVimeo,.addToReadingList,.saveToCameraRoll,.assignToContact]

    UIViewController.getTopVC()?.present(activityViewController, animated: true, completion: nil)
  }
}
