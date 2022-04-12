//
//  CCTShopFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/12.
//

import UIKit

class CCTShopFooterView: UICollectionReusableView {
        
  @IBOutlet weak var searchView: ShopSearchView!
  var filterHandler:(()->())!
  @IBAction func filterButtonAction(_ sender: Any) {
    filterHandler()
  }
}
