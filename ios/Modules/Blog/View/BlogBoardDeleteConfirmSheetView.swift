//
//  BlogBoardDeleteConfirmSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/11.
//

import UIKit

class BlogBoardDeleteConfirmSheetView: UIView {

  private var confirmHandler:(()->())?
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    titleLabel.textAlignment = .center
    messageLabel.textAlignment = .center
  }
  static func show(confirmHandler:(()->())?) {
    let view = BlogBoardDeleteConfirmSheetView.loadViewFromNib()
    view.confirmHandler = confirmHandler
    let size = CGSize(width: kScreenWidth, height: 276 + kBottomsafeAreaMargin)
    EntryKit.displayView(asSheet: view, size: size)
  }
  @IBAction func cancelButtonAction(_ sender: Any) {
    EntryKit.dismiss()
  }
  
  @IBAction func confirmButtonAction(_ sender: Any) {
    EntryKit.dismiss {
      self.confirmHandler?()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }


}
