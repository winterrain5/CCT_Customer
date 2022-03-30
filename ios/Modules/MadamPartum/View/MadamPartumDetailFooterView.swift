//
//  MadamPartumDetailFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/21.
//

import UIKit

class MadamPartumDetailFooterView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {

   
  @IBOutlet weak var clvContainer: UIView!
  @IBOutlet weak var pageControl: UIPageControl!
  lazy var collectionView:UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.sectionInset = .zero
    layout.itemSize = CGSize(width: kScreenWidth, height: 224)
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
  var models:[ClientReviewModel] = [] {
    didSet {
      collectionView.reloadData()
      pageControl.numberOfPages = models.count
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    
    pageControl.currentPageIndicatorTintColor = UIColor(hexString: "#EE8F7B")
    pageControl.pageIndicatorTintColor = UIColor(hexString: "#EE8F7B")?.withAlphaComponent(0.2)
    clvContainer.addSubview(collectionView)
    collectionView.register(nibWithCellClass: MadamPartumDetailFooterCell.self)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: MadamPartumDetailFooterCell.self, for: indexPath)
    if models.count > 0 {
      cell.model = models[indexPath.item]
    }
    return cell
  }
  
 
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    pageControl.currentPage = indexPath.item
  }
}
