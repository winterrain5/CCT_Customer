//
//  ShopFilterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/9.
//

import UIKit

@objcMembers
class ShopFilterView: UIView {
  static let shared = ShopFilterView()
  var contentView = ShopFilterContentView.loadViewFromNib()
  var scrollView = UIScrollView()
  var selectCompleteHandler:((String)->())?
  lazy var updateButton = UIButton().then { btn in
    btn.titleForNormal = "Update"
    btn.titleColorForNormal = .white
    btn.backgroundColor = R.color.theamRed()
    btn.cornerRadius = 22
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.addTarget(self, action: #selector(self.updateButtonAction), for: .touchUpInside)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.updateHeightHandler = { [weak self] height in
      self?.scrollView.contentSize = CGSize(width: kScreenWidth, height: height + kBottomsafeAreaMargin + 36)
      self?.contentView.height = (self?.scrollView.contentSize.height)!
    }
    
    addSubview(updateButton)
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    
    scrollView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight * 0.8 - 32)
    contentView.frame = scrollView.bounds
    updateButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(16 + kBottomsafeAreaMargin)
    }
  }
  
  @objc func updateButtonAction() {
    EntryKit.dismiss()
    selectCompleteHandler?(contentView.result.jsonString() ?? "")
    print(contentView.result.jsonString() ?? "")
  }
  
  static func show(_ isNew:Bool,complete: @escaping (String)->()) {
    var view:ShopFilterView!
    if isNew {
      view = ShopFilterView()
    }else {
      view = ShopFilterView.shared
    }
    view.selectCompleteHandler = complete
    
    let size = CGSize(width: kScreenWidth, height: kScreenHeight * 0.8)
    EntryKit.display(view: view, size: size, style: .sheet)

  }

}
