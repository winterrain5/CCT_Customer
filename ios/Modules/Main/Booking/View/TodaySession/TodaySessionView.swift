//
//  TodaySessionView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/18.
//

import UIKit
import CHIPageControl
class TodaySessionView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {
  var models:[BookingTodayModel] = [] {
    didSet {
      collectionView.reloadData()
      pageControl.numberOfPages = models.count
    }
  }
  
  lazy var layout = PagingCollectionViewLayout().then { layout in
    layout.scrollDirection = .horizontal
    layout.sectionInset = .zero
    layout.itemSize = CGSize(width: kScreenWidth, height: 196)
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
  }
  
  lazy var collectionView:UICollectionView = {
    let view = UICollectionView(frame: .zero,collectionViewLayout: layout)
    view.showsHorizontalScrollIndicator = false
    view.backgroundColor = .clear
    view.delegate = self
    view.dataSource = self
    view.isPagingEnabled = true
    return view
  }()
  var pageControl = CHIPageControlJaloro().then { pageControl in
    pageControl.currentPageTintColor = R.color.theamBlue()!
    pageControl.tintColor = R.color.theamBlue()?.withAlphaComponent(0.2)
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.hidesForSinglePage = false
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(collectionView)
    collectionView.register(nibWithCellClass: TodaySessionCell.self)
    
    addSubview(pageControl)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    collectionView.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
      make.height.equalTo(196)
    }
    pageControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().offset(-8)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: TodaySessionCell.self, for: indexPath)
    if models.count > 0 {
      cell.model = models[indexPath.item]
    }
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = BookingUpComingDetailController(today: models[indexPath.item])
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, animated: true)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x == 0 {
      pageControl.set(progress: 0, animated: true)
    }else {
      let page = (scrollView.contentOffset.x / kScreenWidth).int
      pageControl.set(progress: page, animated: true)
    }
   
  }
}
