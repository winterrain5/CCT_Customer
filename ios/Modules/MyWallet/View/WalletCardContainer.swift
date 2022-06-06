//
//  WalletCardContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/2.
//

import UIKit

class WalletCardContainer: UIView {

  @IBOutlet weak var pointsLabel: UILabel!
  @IBOutlet weak var pointsExpiresDateLabel: UILabel!
  @IBOutlet weak var shadowView: UIView!
  let card = WalletCardView.loadViewFromNib()
  var model:UserModel? {
    didSet {
      guard let userModel = model else { return }
   
      let point = userModel.points.int.string
      pointsLabel.text = String(point)
      card.model = model
      
      hideSkeleton()
    }
    
  }
  
  var money:String = "" {
    didSet {
      card.money = money
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    shadowView.addSubview(card)
    showSkeleton()
  }
  

  override func layoutSubviews() {
    super.layoutSubviews()
    card.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
  }
  
}
