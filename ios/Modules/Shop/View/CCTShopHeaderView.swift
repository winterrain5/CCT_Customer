//
//  CCTShopHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/12.
//

import UIKit
import CHIPageControl
class CCTShopHeaderView: UICollectionReusableView,FSPagerViewDelegate,FSPagerViewDataSource {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var pageControl: CHIPageControlJaloro!
  @IBOutlet weak var bannerContentView: UIView!
  lazy var pagerView = FSPagerView().then { view in
    view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
    view.delegate = self
    view.dataSource = self
    view.isInfinite = true
    view.automaticSlidingInterval = 3
    
  }
  var isCCT = false {
    didSet {
      if isCCT {
        pageControl.currentPageTintColor = R.color.theamBlue()
        pageControl.tintColor =  R.color.theamBlue()?.withAlphaComponent(0.2)
        titleLabel.text = "Chien Chi Tow"
        titleLabel.textColor = R.color.theamBlue()
      }else {
        pageControl.currentPageTintColor =  R.color.theamPink()
        pageControl.tintColor = R.color.theamPink()?.withAlphaComponent(0.2)
        titleLabel.text = "Madam Partum"
        titleLabel.textColor = R.color.theamPink()
      }
    }
  }
  var datas:[ShopProductModel] = [] {
    didSet {
      pagerView.reloadData()
      pageControl.numberOfPages = datas.count
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.progress = 0
    
    bannerContentView.addSubview(pagerView)
    bannerContentView.bringSubviewToFront(pageControl)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    pagerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  @IBAction func filterButtonAction(_ sender: Any) {
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
    
//    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }

  func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
    pageControl.set(progress: index, animated: true)
  }
}
