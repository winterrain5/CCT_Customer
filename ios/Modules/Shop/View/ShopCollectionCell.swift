//
//  ShopCollectionCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit
import CHIPageControl

enum ShopDataType {
  case RecentlyViewed
  case NewProducts
  case Other
}
class ShopCollectionCell: UITableViewCell,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
  var typeLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:24)
    label.lineHeight = 36
  }
  var viewButton = UIButton().then { btn in
    btn.titleForNormal = "View All"
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.titleColorForNormal = R.color.theamRed()
  }
  lazy var layout = PagingCollectionViewLayout().then { layout in
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 8
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
  }
  lazy var collectionView:UICollectionView = {
    
    let view = UICollectionView(frame: .zero,collectionViewLayout: layout)
    view.showsHorizontalScrollIndicator = false
    view.backgroundColor = .white
    view.delegate = self
    view.dataSource = self
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
    pageControl.hidesForSinglePage = false
  }
  
  var clvH:CGFloat = 0
  var dataType:ShopDataType = .NewProducts {
    didSet {
      
      if dataType == .NewProducts {
        self.typeLabel.text = "New Products"
        viewButton.isHidden = false
      }
      if dataType == .RecentlyViewed {
        self.typeLabel.text = "Recently Viewed"
        viewButton.isHidden = false
      }
      if dataType == .Other {
        self.typeLabel.text = "Other Products"
        viewButton.isHidden = true
      }
      
    }
  }
  var datas:[ShopProductModel] = [] {
    didSet {
      collectionView.reloadData()
      pageControl.numberOfPages = (datas.count / 2) + ( datas.count % 2 == 0 ? 0 : 1 )
    }
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configSubViews()
  }
  
  func configSubViews() {
    contentView.addSubview(typeLabel)
    contentView.addSubview(viewButton)
    contentView.addSubview(collectionView)
    contentView.addSubview(pageControl)
    
    self.collectionView.register(nibWithCellClass: ShopProductItemCell.self)
    self.clvH = 184
    self.layout.itemSize = CGSize(width: 160, height: self.clvH)
    self.layout.numberOfItemsPerPage = 2
    
    viewButton.addTarget(self, action: #selector(viewButtonAction), for: .touchUpInside)
  }
  
  @objc func viewButtonAction() {
    let vc = ShopViewAllController(dataType: dataType)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    typeLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(16)
    }
    
    viewButton.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(24)
      make.centerY.equalTo(typeLabel)
    }
    collectionView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(typeLabel.snp.bottom).offset(16)
      make.height.equalTo(clvH)
    }
    pageControl.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalToSuperview().inset(16)
      make.height.equalTo(4)
    }
  }
  

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datas.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: ShopProductItemCell.self, for: indexPath)
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
    }
    cell.likeHandler = { [weak self] model in
      self?.updateCellIsLikeStatus(model)
    }
    return cell
  }
  
  
  
  func updateCellIsLikeStatus(_ model:ShopProductModel) {
    guard let index = self.datas.firstIndex(where: { $0.id == model.id }) else {
      return
    }
    self.datas[index].isLike = model.isLike
    let indexPath = IndexPath(item: index, section: 0)
    self.collectionView.reloadItems(at: [indexPath])
  }
  
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let id = self.datas[indexPath.item].id
    let vc = ShopDetailController(productId: id)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x == 0 {
      pageControl.set(progress: 0, animated: true)
    }else {
      let page = (scrollView.contentOffset.x / 336).int + ((scrollView.contentOffset.x.int % 336 == 0)  ? 0 : 1)
      pageControl.set(progress: page, animated: true)
    }
   
  }
}
