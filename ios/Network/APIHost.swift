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
var URL_API_END_HOST = "/ws&ws=1";

@objcMembers
class APIHost:NSObject {
  
//  var STRIPE_PK_LIVE:String = "pk_live_51HeuTsLmFtI0ErhWJcFdd49fESvMq2PCKXJWE5V6S3O1d8uXCeU9JKZPNLQrnBRa9DND2e8t74GirQaGWXwc0p7H00TWoGgRvm"
  
  var STRIPE_PK_LIVE:String = "pk_test_51J2RALDOZGW531kA4P9Hed5lkH5ldQ7dfZipqVbKUSTNRP4iu5ch2DQyvekxmOFyiLWlPiybjtuxfHxvWvTZXo2f00Kl6UhnVd"
  
  
//  var URL_API_HOST:String = "http://tispcctapp.performsoftware.biz/index.php?r="
//  var URL_API_IMAGE:String = "http://cct.performsoftware.biz"
//  var URL_BLOG_SHARE:String =  "http://cct.performsoftware.biz/index.php?r=blog-view/index&id="
//  var URL_API_UUID:String = "http://cct.performsoftware.biz/index.php?r=user-manager/change-find-pwd-status&uuid="
  
  var URL_API_HOST:String = "http://tispcctuat.performsoftware.biz/index.php?r="
  var URL_API_IMAGE:String = "http://cctuat.performsoftware.biz"
  var URL_BLOG_SHARE:String = "http://cctuat.performsoftware.biz/index.php?r=blog-view/index&id="
  var URL_API_UUID:String = "http://cctuat.performsoftware.biz/index.php?r=user-manager/change-find-pwd-status&amp;uuid="



//  var URL_API_HOST:String = "http://10.1.3.90:8081/tisp/index.php?r="
//  var URL_API_IMAGE:String = "http://10.1.3.90:8081/tcm"
//  var URL_BLOG_SHARE:String = "http://10.1.3.90:8081/tcm/index.php?r=blog-view/index&id="
//  var URL_API_UUID:String = "http://10.1.3.90:8081/tcm/index.php?r=user-manager/change-find-pwd-status&uuid="


 
}
