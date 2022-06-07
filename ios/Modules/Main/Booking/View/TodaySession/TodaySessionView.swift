//
//  TodaySessionView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/18.
//

import UIKit
import CHIPageControl
class TodaySessionView: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
  
  var todayHeight:CGFloat = 0
  var itemWidth:CGFloat = 0
  var models:[BookingTodayModel] = [] {
    didSet {
      todayHeight = 0
      let addtionalH = models.filter({ $0.staff_is_random == "2" }).count > 0 ? 28 : 0
      let clvH = 192 + addtionalH.cgFloat
      let controlH:CGFloat = models.count > 1 ? 24 : 0
      todayHeight = todayHeight + clvH + controlH
      collectionView.snp.makeConstraints { make in
        make.left.right.top.equalToSuperview()
        make.height.equalTo(clvH)
      }
      pageControl.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.top.equalTo(collectionView.snp.bottom).offset(8)
      }
      itemWidth = models.count > 1 ? kScreenWidth * 0.8 : (kScreenWidth - 32)
      collectionView.reloadData()
      pageControl.numberOfPages = models.count
      
    }
  }
  
  lazy var layout = PagingCollectionViewLayout().then { layout in
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
    view.decelerationRate = .fast
    return view
  }()
  var pageControl = CHIPageControlJaloro().then { pageControl in
    pageControl.currentPageTintColor = R.color.theamBlue()!
    pageControl.tintColor = R.color.theamBlue()?.withAlphaComponent(0.2)
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.hidesForSinglePage = true
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
      let page = floor((scrollView.contentSize.width / scrollView.contentOffset.x))
      pageControl.set(progress: page.int - 1, animated: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if models.count > 0 {
      let itemH = models[indexPath.item].cellHeight
      return CGSize(width: itemWidth, height: itemH)
    }
    return .zero
  }
  
}
