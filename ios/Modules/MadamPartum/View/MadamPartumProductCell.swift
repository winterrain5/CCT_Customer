//
//  MadamPartumProductCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit

class MadamPartumProductCell: MadamPartumCell {
  private var selectProductId:String = ""
  var datas:[FeatureProductModel] = [] {
    didSet {
      collectionView.reloadData()
      pageControl.numberOfPages = datas.count / 2
    }
  }
  override func configSubViews() {
    self.clvH = 184
    self.layout.itemSize = CGSize(width: 160, height: self.clvH)
    self.layout.numberOfItemsPerPage = 2
   
    super.configSubViews()
    
    self.collectionView.register(nibWithCellClass: MadamPartumProductItemCell.self)
    self.typeLabel.text = "Products"
    self.viewButton.titleForNormal = "View Shop"
    self.viewButton.isHidden = false
  }
  
  override func viewButtonAction() {
    let vc = RNBridgeViewController(RNPageName: "ShopActivity", RNProperty: [:])
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datas.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: MadamPartumProductItemCell.self, for: indexPath)
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
    }
    cell.likeHandler = { [weak self] model in
      self?.selectProductId = model.id!
      if model.isLike ?? false {
        self?.deleteLikeProduct(model)
      }else {
        self?.saveLikeProduct(model)
      }
    }
    return cell
  }
  
  func saveLikeProduct(_ model:FeatureProductModel) {
    let params = SOAPParams(action: .Product, path: .saveLikeProduct)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "productId", value: model.id ?? "")
    
    NetworkManager().request(params: params) { data in
      self.updateCellIsLikeStatus(true)
    } errorHandler: { e in
      
    }

  }
  
  func deleteLikeProduct(_ model:FeatureProductModel) {
    let params = SOAPParams(action: .Product, path: .deleteLikeProduct)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "productId", value: model.id ?? "")
    
    NetworkManager().request(params: params) { data in
      self.updateCellIsLikeStatus(false)
    } errorHandler: { e in
      
    }
  }
  
  func updateCellIsLikeStatus(_ isLike:Bool) {
    guard let index = self.datas.firstIndex(where: { $0.id == self.selectProductId }) else {
      return
    }
    self.datas[index].isLike = isLike
    let indexPath = IndexPath(item: index, section: 0)
    self.collectionView.reloadItems(at: [indexPath])
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = datas[indexPath.item]
    let vc = RNBridgeViewController(RNPageName: "ShopProductDetailActivity", RNProperty: ["product_id":model.id ?? ""])
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
}
