//
//  HomeKingKongView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/2.
//

import UIKit

struct KingKongModel {
  var image:UIImage?
  var title:String
  var sel:String
}

class HomeKingKongView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
  lazy var datas:[KingKongModel] = []
  
  lazy var layout = UICollectionViewFlowLayout().then { layout in
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 80, height: 84)
    
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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    datas = [
      KingKongModel(image: R.image.home_kk_symptom_check(), title: "Symptom\nChecker", sel: "symptomChecker"),
      KingKongModel(image: R.image.home_kk_shop(), title: "shop", sel: "shop"),
      KingKongModel(image: R.image.home_kk_treament(), title: "Conditions\nWe Treat", sel: "conditionsWeTreat"),
      KingKongModel(image: R.image.home_kk_mp(), title: "Madam\nPartum", sel: "madamPartum"),
    ]
    layout.minimumInteritemSpacing = (kScreenWidth - 48) / (datas.count - 1).cgFloat
    addSubview(collectionView)
    collectionView.register(cellWithClass: HomeKingKongCell.self)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datas.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: HomeKingKongCell.self, for: indexPath)
    cell.model = datas[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  
  }
  
  

}

class HomeKingKongCell:UICollectionViewCell {
  var imageView = UIImageView().then { img in
    img.contentMode = .center
    img.backgroundColor = R.color.theamYellow()
    img.cornerRadius = 22
  }
  var label = UILabel().then { label in
    label.textColor = .black
    label.font = UIFont(name: .AvenirNextRegular, size: 12)
    label.numberOfLines = 2
  }
  var model:KingKongModel! {
    didSet {
      imageView.image = model.image
      label.text = model.title
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    contentView.addSubview(label)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    imageView.snp.makeConstraints { make in
      make.width.height.equalTo(44)
      make.centerX.equalToSuperview()
      make.top.equalToSuperview()
    }
    label.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(imageView.snp.bottom).offset(8)
    }
  }
}
