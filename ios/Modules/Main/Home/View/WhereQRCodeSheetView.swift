//
//  WhereQRCodeSheetView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/13.
//

import UIKit

class WhereQRCodeSheetView: UIView {

  override func awakeFromNib() {
    super.awakeFromNib()
    rx
      .tapGesture()
      .when(.recognized)
      .subscribe(onNext: { _ in
        EntryKit.dismiss()
      })
      .disposed(by: rx.disposeBag)
    
    rx.swipeGesture(.down, configuration: nil).subscribe { _ in
      EntryKit.dismiss()
    }.disposed(by: rx.disposeBag)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

}
