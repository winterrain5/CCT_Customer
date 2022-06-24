//
//  ServiceFormCell.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/20.
//

import UIKit

class BookingServiceFormCell: UITableViewCell,UITextFieldDelegate {

  var label = UILabel().then { label in
    label.textColor = R.color.gray82()
    label.font = UIFont(name: .AvenirNextRegular, size: 16)
  }
  var rightImage = UIImageView().then { img in
    img.image = R.image.booking_form_dropdown()
  }
  var textInput = UITextField().then { tf in
    tf.borderStyle = .none
    tf.placeholder = "Additional Note"
    tf.font = UIFont(name: .AvenirNextRegular, size: 16)
    tf.textColor = .black
  }
  var textInputEditEndHandler:((String)->())?
  var model:ServiceFormModel! {
    didSet {
      
      if model.type != .note {
        label.isHidden = false
        textInput.isHidden = true
        if model.title.isEmpty {
          label.text = model.placeHolder
          label.textColor = R.color.gray82()
        }else {
          label.text = model.title
          label.textColor = R.color.black()
        }
        rightImage.image = model.rightImage
      }else {
        label.isHidden = true
        textInput.isHidden = false
        textInput.placeholder = model.placeHolder
        textInput.text = model.title
        rightImage.image = nil
      }
      
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(label)
    contentView.addSubview(rightImage)
    contentView.addSubview(textInput)
    textInput.delegate = self
    textInput.setPlaceHolderTextColor(R.color.gray82()!)
    textInput.returnKeyType = .done
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    label.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-32)
      make.top.equalToSuperview().offset(30)
    }
    
    rightImage.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(label)
    }
    
    textInput.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview()
      make.height.equalTo(46)
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.textInputEditEndHandler?(textField.text ?? "")
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    return true
  }
}
