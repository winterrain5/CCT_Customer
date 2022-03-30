//
//  MadamPartumCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit
import CHIPageControl
class MadamPartumCell: UITableViewCell,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
  var typeLabel = UILabel().then { label in
    label.text = "Service"
    label.textColor = UIColor(hexString: "#6F1E42")
    label.font = UIFont(.AvenirNextDemiBold,24)
    label.lineHeight = 36
  }
  var viewButton = UIButton().then { btn in
    btn.titleForNormal = "view blog"
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
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
    pageControl.currentPageTintColor = UIColor(hexString: "#EE8F7B")
    pageControl.tintColor = UIColor(hexString: "#EE8F7B")?.withAlphaComponent(0.2)
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.hidesForSinglePage = false
  }
  var clvH:CGFloat = 0
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configSubViews()
  }
  
  func configSubViews() {
    contentView.addSubview(typeLabel)
    contentView.addSubview(viewButton)
    contentView.addSubview(collectionView)
    contentView.addSubview(pageControl)
    viewButton.addTarget(self, action: #selector(viewButtonAction), for: .touchUpInside)
  }
  
  @objc func viewButtonAction() {
    
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
    return 6
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x == 0 {
      pageControl.set(progress: 0, animated: true)
    }else {
      let page = floor((scrollView.contentSize.width / scrollView.contentOffset.x))
      pageControl.set(progress: page.int - 1, animated: true)
    }
   
  }
}
