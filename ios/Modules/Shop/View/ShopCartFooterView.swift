//
//  ShopCartFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/14.
//

import UIKit

class ShopCartFooterView: UIView {

  @IBOutlet weak var totalItemLabel: UILabel!
  
  @IBOutlet weak var subTotalPriceLabel: UILabel!
  
  @IBOutlet weak var totalPriceLabel: UILabel!
  
  func update(count:Int,subTotal:String,total:String) {
    totalItemLabel.text = count.string
    subTotalPriceLabel.text = subTotal
    totalPriceLabel.text = total
  }
}
