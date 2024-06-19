//
//  MyOrderHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class MyOrderHeaderView: UIView {

  var buttons:[UIButton] = []
  var selectButton:UIButton?
  
  var statusDidClickHandler:((Int)->())?


  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    
    addTags("In Progress",tag: 0)
    addTags("Completed",tag: 1)
    addTags("Cancelled",tag: 2)
    
    buttonAction(buttons[0])
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  
    let padding = 20
    let margin = 16
    let width = 90
    buttons.enumerated().forEach { i,e in
      let x = (margin + width) * i + margin
      
      e.frame = CGRect(x: x.cgFloat, y: 20, width: width.cgFloat, height: 36)
    }
  }
  
  func addTags(_ text:String,tag:Int) {
    
    let button = UIButton()
    button.tag = tag
    button.backgroundColor = R.color.placeholder()!
    button.titleForNormal  = text
    button.titleColorForNormal = .black
    button.titleColorForSelected = .white
    button.cornerRadius = 18
    button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    buttons.append(button)
    
    addSubview(button)
  }
  
  @objc func buttonAction(_ sender:UIButton)  {
    
    selectButton?.isSelected.toggle()
    
    if selectButton?.isSelected ?? false{
      selectButton?.backgroundColor = R.color.theamRed()!
    } else {
      selectButton?.backgroundColor = R.color.placeholder()!
    }
    
    sender.isSelected.toggle()
    
    if sender.isSelected {
      sender.backgroundColor = R.color.theamRed()!
    } else {
      sender.backgroundColor = R.color.placeholder()!
    }
    
    selectButton = sender
    
  
    
    statusDidClickHandler?(sender.tag)
  }
 

}
