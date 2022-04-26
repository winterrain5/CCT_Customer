//
//  ConditionWeTreatController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/16.
//

import UIKit
import WebKit
class ConditionWeTreatController: BaseViewController,WKNavigationDelegate {
  private var webView: WebView!
  private lazy var footerView = UIView().then { view in
    view.backgroundColor = .white
    
    let btn = UIButton()
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.titleForNormal = "Book an Appointment"
    btn.titleColorForNormal = R.color.white()
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.addTarget(self, action: #selector(bookAppointmentAction), for: .touchUpInside)
    btn.frame = CGRect(x: 16, y: 12, width: kScreenWidth - 32, height: 44)
    view.addSubview(btn)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    let configuration = WKWebViewConfiguration()
    configuration.allowsInlineMediaPlayback = true
    configuration.mediaTypesRequiringUserActionForPlayback = .all
    configuration.preferences = WKPreferences()
    configuration.preferences.javaScriptEnabled = true
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
    configuration.processPool = WKProcessPool()
    configuration.userContentController = WKUserContentController()
    configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
    webView = WebView(frame: CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight),configuration: configuration)
   
    webView.navigationDelegate = self
    self.view.addSubview(webView)
    let req = URLRequest(url: URL_Conditions_We_Treat.url!, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 8)
    webView.load(req)
    
    
  }
  
  @objc func bookAppointmentAction() {
    let params = SOAPParams(action: .Client, path: .getClientCancelCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      let count = JSON.init(from: data)?["cancel_count"].rawString()?.int ?? 0
      if count > 3 {
        AlertView.show(message: "If you delay cancelling more than 3 times, your in app reservation permission will be suspended.")
      }else {
        let vc = RNBridgeViewController(RNPageName: "BookAppointmentActivity", RNProperty: ["select_type":"0"])
        UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
      }
    } errorHandler: { e in
      Toast.dismiss()
    }

    
  }
  
  /// 页面开始加载时调用
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    Toast.showLoading()
    print("页面开始加载\n\(webView.url?.absoluteString ?? "")")
  }
 
  /// 页面加载完成之后调用
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    Toast.dismiss()
    let url = webView.url?.absoluteString ?? ""
    if url == "http://info.chienchitow.com/our-treatment-plan/" {
      webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 88, right: 0)
      self.view.addSubview(footerView)
      footerView.frame = CGRect(x: 0, y: kScreenHeight - 88, width: kScreenWidth, height: 88)
    }else {
      webView.scrollView.contentInset = .zero
      footerView.removeFromSuperview()
    }
    print("页面加载完成\(url)")
    
  }
  
  /// 加载失败时调用
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    Toast.dismiss()
  }
}
