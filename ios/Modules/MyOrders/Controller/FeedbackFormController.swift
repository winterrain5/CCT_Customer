//
//  FeedbackFormController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit

class FeedbackFormController: BaseViewController {
  var contentView = FeedbackFormContainer.loadViewFromNib()
  var scrollView = UIScrollView()
  private var bookingTimeId:String = ""
  convenience init(bookingTimeId:String) {
    self.init()
    self.bookingTimeId = bookingTimeId
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(scrollView)
    scrollView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    scrollView.contentSize = CGSize(width: kScreenWidth , height: 1346)
    
    scrollView.addSubview(contentView)
    contentView.bookingTimeId = bookingTimeId
    contentView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 1346)
  }
  
  
  
  
}
