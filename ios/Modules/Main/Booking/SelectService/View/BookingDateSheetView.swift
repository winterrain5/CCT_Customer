//
//  BookingDateSheetView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/23.
//

import UIKit

class BookingDateSheetView: UIView {

  var titleLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 18)
  }
  var lineLayer = CAShapeLayer().then { layer in
    layer.backgroundColor = R.color.grayf2()?.cgColor
  }
  var dataArray:[String] = [] {
    didSet {
     
    }
  }

  var selectComplete:((Int)->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(titleLabel)
    layer.addSublayer(lineLayer)
  }
  
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(24)
      make.height.equalTo(28)
    }
   
    lineLayer.frame = CGRect(x: 0, y: 68, width: kScreenWidth, height: 1)
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  

  static func show(dataArray:[String],selectComplete:@escaping (Int)->()) {
    let view = BookingServiceFormSheetView()
    view.dataArray = dataArray
    view.selectComplete = selectComplete
    
    let size = CGSize(width: kScreenWidth, height: 405)
    EntryKit.display(view: view, size: size, style: .sheet)
  }

}
