//
//  ServicesViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import UIKit

class OurServicesViewController: BaseCollectionController,UICollectionViewDelegateFlowLayout {
  private var headerView:ServicesHeaderView?
  private var footerView:ServicesFooterView?
  ///  all: nil treament:2 wellness 1,3
  private var category:String = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigation.item.title = "Services"
    refreshData()
  }
  
  override func refreshData() {
    let params = SOAPParams(action: "service", path: API.getOurServicesByCategory)
    params.setValue(key: "wellnessTreatTypes", value: category)
    NetworkManager.shared.request(params: params) { data in
      
      
    } errorHandler: { error in
      self.endRefresh(error.emptyDatatype)
    }

  }
  
  override func backAction() {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func createListView() {
    super.createListView()
    
    collectionView?.register(nibWithCellClass: ServiceListCell.self)
    collectionView?.register(nib: UINib(nibName: "ServicesHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: ServicesHeaderView.self)
    collectionView?.register(nib: UINib(nibName: "ServicesFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withClass: ServicesFooterView.self)
    registRefreshFooter()
    registRefreshHeader(colorStyle: .gray)
  }
  
  override func listViewLayout() -> UICollectionViewLayout {
    let layout = HoverViewFlowLayout(navHeight: 0)
    layout.sectionInset = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    return layout
  }
 
  func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 2
  }
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      if section == 1 {
          return 10
      }
      return 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withClass: ServiceListCell.self, for: indexPath)
      
      return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
      if indexPath.section == 0 {
          if kind == UICollectionView.elementKindSectionHeader {
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: ServicesHeaderView.self, for: indexPath)
             headerView = header
              return header
          }
        
        if kind == UICollectionView.elementKindSectionFooter {
          let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: ServicesFooterView.self, for: indexPath)
          footerView = footer
          return footer
        }
          
      }
      return UICollectionReusableView.init()
  }
  
  //UICollectionViewDelegateFlowLayout
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
      return section == 0 ? CGSize.init(width:kScreenWidth, height:252) : .zero
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
      return section == 0 ? CGSize(width: kScreenWidth, height: 84) : .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (kScreenWidth - 22) * 0.5
    let height:CGFloat = 420
    return CGSize(width: width, height: height)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
  }
  
}
