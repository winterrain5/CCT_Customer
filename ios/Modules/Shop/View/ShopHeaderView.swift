//
//  ShopHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit
import CHIPageControl
class ShopHeaderView: UIView,FSPagerViewDelegate,FSPagerViewDataSource {
  
  @IBOutlet weak var cctButton: UIButton!
  @IBOutlet weak var mpButton: UIButton!
  @IBOutlet weak var pageControl: CHIPageControlJaloro!
  @IBOutlet weak var bannerContentView: UIView!
  lazy var pagerView = FSPagerView().then { view in
    view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
    view.delegate = self
    view.dataSource = self
    view.isInfinite = true
    view.automaticSlidingInterval = 3
    
  }
  var datas:[ShopProductModel] = [] {
    didSet {
      pagerView.reloadData()
      pageControl.numberOfPages = datas.count
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    
    pageControl.currentPageTintColor = R.color.theamBlue()!
    pageControl.tintColor = R.color.theamBlue()?.withAlphaComponent(0.2)
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.progress = 0
    
    bannerContentView.addSubview(pagerView)
    bannerContentView.bringSubviewToFront(pageControl)
    
    cctButton.titleForNormal = ""
    mpButton.titleForNormal = ""
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    pagerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  
  public func numberOfItems(in pagerView: FSPagerView) -> Int {
    return datas.count
  }
  
  public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
    let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
    if datas.count > 0 {
      cell.imageView?.yy_setImage(with: datas[index].picture.asURL, options: .setImageWithFadeAnimation)
    }
    cell.imageView?.contentMode = .scaleAspectFill
    cell.imageView?.isUserInteractionEnabled = true
    return cell
  }
  
  func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
    return true
  }
  func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
    pagerView.deselectItem(at: index, animated: false)
    let model = datas[index]
    let vc = ShopDetailController(productId: model.id)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
  func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
    pageControl.set(progress: index, animated: true)
  }
  
  @IBAction func cctButtonAction(_ sender: Any) {
    let vc = CCTShopController(isCCT: true)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
  @IBAction func mpButtonAction(_ sender: Any) {
    let vc = CCTShopController(isCCT: false)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
}
