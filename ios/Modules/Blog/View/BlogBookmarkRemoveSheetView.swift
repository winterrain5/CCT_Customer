//
//  BlogBookmarkRemoveSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/10.
//

import UIKit

class BlogBookmarkRemoveSheetView: UIView {
  
  private var confirmHandler:(()->())?
  @IBOutlet weak var titleLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    titleLabel.textAlignment = .center
  }
  static func show(confirmHandler:(()->())?) {
    let view = BlogBookmarkRemoveSheetView.loadViewFromNib()
    view.confirmHandler = confirmHandler
    let size = CGSize(width: kScreenWidth, height: 213 + kBottomsafeAreaMargin)
    EntryKit.display(view: view, size: size, style: .sheet, backgroundColor: R.color.blackAlpha8()!, touchDismiss: true)
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
