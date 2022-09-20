//
//  WalletCouponsCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

class WalletCouponsCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
  var coupons:[WalletCouponsModel] = [] {
    didSet {
      self.shouldDisplay = !(coupons.count > 0)
      self.collectionView.reloadData()
      self.collectionView.reloadEmptyDataView()
    }
  }
  
  var shouldDisplay:Bool = false
  var emptyString:NSMutableAttributedString = {
    let str = "You have no new Vouchers"
    let attr = NSMutableAttributedString(string: str)
    attr.addAttribute(.font, value: UIFont(name:.AvenirNextRegular,size:16), range: NSRange(location: 0, length: str.count))
    return attr
  }()
  
  @IBOutlet weak var collectionView: UICollectionView!
  override func awakeFromNib() {
    super.awakeFromNib()
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 160, height: 196)
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    collectionView.collectionViewLayout = layout
    collectionView.register(nibWithCellClass: WalletVoucherCouponsCell.self)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.delegate = self
    collectionView.dataSource = self
    
    collectionView.emptyDataView { [weak self] view in
      guard let `self` = self else { return }
      view.shouldDisplay(self.shouldDisplay)
      view.detailLabelString(self.emptyString)
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return coupons.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: WalletVoucherCouponsCell.self, for: indexPath)
    if coupons.count > 0 {
      cell.coupon = coupons[indexPath.item]
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    let vc = RewardsDetailController(type: .watch,coupon: coupons[indexPath.item])
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
}
