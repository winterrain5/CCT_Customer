//
//  TodaySessionView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/18.
//

import UIKit

class TodaySessionView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {
  var models:[BookingTodayModel] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  lazy var collectionView:UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.sectionInset = .zero
    layout.itemSize = CGSize(width: kScreenWidth, height: 196)
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    let view = UICollectionView(frame: .zero,collectionViewLayout: layout)
    view.showsHorizontalScrollIndicator = false
    view.backgroundColor = .clear
    view.delegate = self
    view.dataSource = self
    view.isPagingEnabled = true
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(collectionView)
    collectionView.register(nibWithCellClass: TodaySessionCell.self)
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
}
