//
//  BlogDetailViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/7.
//

import UIKit
import SkeletonView
class BlogDetailViewController: BaseViewController {
  private var scrollView = UIScrollView().then { view in
    view.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin, right: 0)
  }
  
  private var contentView = BlogDetailContainer.loadViewFromNib()
  var blogId:String = ""
  var hasBook:Bool = false
  convenience init(blogId:String,hasBook:Bool) {
    self.init()
    self.blogId = blogId
    self.hasBook = hasBook
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    view.isSkeletonable = true
    scrollView.isSkeletonable = true
    contentView.isSkeletonable = true
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.setContentCompleteHandler = { [weak self] height in
      self?.scrollView.contentSize = CGSize(width: kScreenWidth, height: height)
    }
    contentView.frame = self.view.bounds
    refreshData()
  }
  
  
  func refreshData() {
    let params = SOAPParams(action: .Blog, path: API.getBlogDetails)
    params.set(key: "id", value: self.blogId)
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeByCodable(BlogDetailModel.self, from: data) {
        model.has_booked = self.hasBook
        self.contentView.model = model
      }
    } errorHandler: { error in
      
    }
    
  }
  
}
