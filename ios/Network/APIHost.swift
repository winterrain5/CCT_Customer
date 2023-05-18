//
//  APIHost.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/10.
//

import Foundation


let URL_OUR_STORY = "http://info.chienchitow.com/about-us/"
let URL_TREAMENT_PLAN = "http://info.chienchitow.com/our-treatment-plan/"
let URL_Conditions_We_Treat = "http://info.chienchitow.com/condition-we-treat/"
let URL_API_END_HOST = "/ws&ws=1";
let REQUEST_TIME_OUT = TimeInterval(16)

let URL_App_Store = "itms-apps://itunes.apple.com/cn/app/qq/id1621220175?mt=8"

enum DomainType {
  case Live
  case UAT
  case DEBUG
}

@objcMembers
class APIHost:NSObject {
  
  var domainType:DomainType = .UAT
  
  var STRIPE_PK_LIVE:String {
    switch domainType {
    case .Live:
      return "pk_live_51HeuTsLmFtI0ErhWJcFdd49fESvMq2PCKXJWE5V6S3O1d8uXCeU9JKZPNLQrnBRa9DND2e8t74GirQaGWXwc0p7H00TWoGgRvm"
    case .UAT:
      return "pk_live_51HeuTsLmFtI0ErhWJcFdd49fESvMq2PCKXJWE5V6S3O1d8uXCeU9JKZPNLQrnBRa9DND2e8t74GirQaGWXwc0p7H00TWoGgRvm"
    case .DEBUG:
      return "pk_test_51J2RALDOZGW531kA4P9Hed5lkH5ldQ7dfZipqVbKUSTNRP4iu5ch2DQyvekxmOFyiLWlPiybjtuxfHxvWvTZXo2f00Kl6UhnVd"
    }
  }
  
  var URL_API_HOST:String {
    get {
      switch domainType {
      case .Live:
        return "http://tispcctapp.performsoftware.biz/index.php?r="
      case .UAT:
        return "http://tispcctuat.performsoftware.biz/index.php?r="
      case .DEBUG:
        return "http://10.1.3.90:8081/tisp/index.php?r="
      }
    }
  }
  var URL_API_IMAGE:String {
    get {
      switch domainType {
      case .Live:
        return "http://cct.performsoftware.biz"
      case .UAT:
        return "http://cctuat.performsoftware.biz"
      case .DEBUG:
        return "http://10.1.3.90:8081/tcm"
      }
    }
  }
  var URL_BLOG_SHARE:String {
    get {
      switch domainType {
      case .Live:
        return "http://cct.performsoftware.biz/index.php?r=blog-view/index&id="
      case .UAT:
        return "http://cctuat.performsoftware.biz/index.php?r=blog-view/index&id="
      case .DEBUG:
        return "http://10.1.3.90:8081/tcm/index.php?r=blog-view/index&id="
      }
    }
  }
  var URL_API_UUID:String {
    get {
      switch domainType {
      case .Live:
        return "http://cct.performsoftware.biz/index.php?r=user-manager/change-find-pwd-status&uuid="
      case .UAT:
        return "http://cctuat.performsoftware.biz/index.php?r=user-manager/change-find-pwd-status&amp;uuid="
      case .DEBUG:
        return "http://10.1.3.90:8081/tcm/index.php?r=user-manager/change-find-pwd-status&uuid="
      }
    }
  }
}
