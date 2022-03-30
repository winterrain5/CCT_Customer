//
//  MadamPartumServiceCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit

class MadamPartumServiceCell: MadamPartumCell {
  var datas:[OurServicesByCategoryModel] = [] {
    didSet {
      collectionView.reloadData()
      pageControl.numberOfPages = datas.count
    }
  }
  override func configSubViews() {
    self.clvH = 454
    self.layout.itemSize = CGSize(width: 210, height: self.clvH)
    self.layout.numberOfItemsPerPage = 1
    self.layout.minimumLineSpacing = 0
    super.configSubViews()
    self.collectionView.register(nibWithCellClass: ServiceListCell.self)
    self.typeLabel.text = "Services"
    self.viewButton.isHidden = true
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datas.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: ServiceListCell.self, for: indexPath)
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
    }
    return cell
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x == 0 {
      pageControl.set(progress: 0, animated: true)
    }else {
      let page = ceil((scrollView.contentOffset.x / 210))
      pageControl.set(progress: page.int, animated: true)
    }
   
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    let url = "http://info.chienchitow.com/services/" +  (datas[indexPath.item].name?.replacingOccurrences(of: " ", with: "-").lowercased() ?? "")
//
//    let vc = WebBrowserController(url: url)
//    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
    let vc = ServiceDetailController(serviceId: datas[indexPath.item].id ?? "")
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
}

