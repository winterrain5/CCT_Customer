//
//  ServicesTagView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import UIKit



class ServicesTagView: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
  
  private lazy var collectionView:UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 10
    layout.sectionInset = .zero
    layout.scrollDirection = .horizontal
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.dataSource = self
    view.delegate = self
    view.showsVerticalScrollIndicator = false
    view.register(cellWithClass: ServicesTagCell.self)
    view.backgroundColor = .white
    return view
  }()
  
  var tags:[String] = [] {
    didSet {
      self.collectionView.reloadData()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  
  internal required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  func setupView() {
    
    addSubview(collectionView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    tags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: ServicesTagCell.self, for: indexPath)
    cell.tagStr = tags[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = floor(tags[indexPath.item].widthWithConstrainedWidth(height: 24, font: UIFont(name: .AvenirHeavy,size: 14))) + 12
    return CGSize(width: width, height: 24)
  }
  
}


class ServicesTagCell: UICollectionViewCell {
  private var titleLabel = UILabel().then { label in
    label.font = UIFont(name: .AvenirHeavy,size: 14)
    label.textColor = .black
    label.textAlignment = .center
  }
  
  var tagStr: String! {
    didSet {
      titleLabel.text = tagStr
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(titleLabel)
    contentView.cornerRadius = 4
    contentView.backgroundColor = UIColor(hexString: "f2f2f2")
  }
  
  internal required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.snp.makeConstraints { make in
      make.edges.equalTo(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
    }
  }
}
