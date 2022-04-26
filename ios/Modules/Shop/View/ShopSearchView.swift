//
//  ShopViewAllSearchView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/11.
//

import UIKit

class ShopSearchView: UIView,UITextFieldDelegate {

  var searchContentView = UIView().then { view in
    view.backgroundColor = .white
    view.borderColor = R.color.grayE0()
    view.borderWidth = 1
    view.cornerRadius = 16
  }
  
  var searchTf = UITextField().then { tf in
    tf.borderStyle = .none
    tf.placeholder = "Search"
    tf.textColor = .black
    tf.font = UIFont(.AvenirNextRegular,16)
  }
  
  var searchDidEndHandler:((String)->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
  }
  
  func setupViews() {
    backgroundColor = .white
    addSubview(searchContentView)
    searchContentView.addSubview(searchTf)
    searchTf.returnKeyType = .search
    searchTf.delegate = self
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    searchContentView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(32)
      make.left.right.equalToSuperview().inset(24)
      make.height.equalTo(40)
    }
    
    searchTf.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.right.equalToSuperview().inset(16)
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  func textFieldDidEndEditing(_ textField: UITextField) {
    
    if let text = textField.text {
      searchDidEndHandler?(text)
    }
    
  }
}
