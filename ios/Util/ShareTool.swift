//
//  ShareTool.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/10.
//

import UIKit
enum ShareType:String {
  case SMS = "message"
  case WHATSAPP = "whatsapp"
  case TELEGRAM = "telegram"
  case EMAIL = "email"
  
  var path:String {
    var url = "";
    switch self {
    case .SMS:
      url = "sms://&body="
    case .WHATSAPP:
      url = "whatsapp://send?text="
    case .TELEGRAM:
      url = "tg://msg?text="
    case .EMAIL:
      url = "mailto:?&body="
    }
    return url
  }
}
class ShareTool {
  static func share(to type:ShareType, _ body:String) {
    guard let url = URL(string: type.path.appending(body)) else { return }
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }else {
      Toast.showError(withStatus: "This app is not allowed to query for scheme \(type.rawValue)")
    }
  }
  
  static func shareBlog(_ title:String,_ url:String) {
    let shareMessage = "\(title):  Learn more to improve your chances for fertility.\n\(url)"
    let shareItems:Array = [shareMessage] as [Any]
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [.postToWeibo,  .addToReadingList, .postToVimeo,.addToReadingList,.saveToCameraRoll,.assignToContact]

    UIViewController.getTopVC()?.present(activityViewController, animated: true, completion: nil)
  }
}
