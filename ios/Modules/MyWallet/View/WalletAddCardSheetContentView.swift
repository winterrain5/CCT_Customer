//
//  WalletAddCardSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit
import IQKeyboardManagerSwift
class WalletAddCardSheetView: UIView {
  var contentView = WalletAddCardSheetContentView.loadViewFromNib()
  let contentHeight:CGFloat = 420
  var scrolview = UIScrollView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    IQKeyboardManager.shared.enableAutoToolbar = true
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    
    
    scrolview.contentSize = CGSize(width: kScreenWidth, height: contentHeight)
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    scrolview.addGestureRecognizer(tap)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  @objc func tapAction(_ ges:UIGestureRecognizer) {
    let location = ges.location(in: scrolview)
    if location.y < (kScreenHeight - contentHeight) {
      dismiss()
    }
  }
  
  func dismiss(complete: (()->())? = nil) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.contentView.frame.origin.y = kScreenHeight
      self.backgroundColor = .clear
    } completion: { flag in
      complete?()
      self.removeFromSuperview()
    }
  }
  
  func show() {
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 2, options: UIView.AnimationOptions.curveEaseIn) {
      self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
      self.contentView.frame.origin.y = kScreenHeight - self.contentHeight
    } completion: { flag in
      
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    scrolview.frame = self.bounds
    contentView.size = CGSize(width: kScreenWidth, height: contentHeight)
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  
  func show(fromView:UIView) {
    
    self.frame = fromView.bounds
    
    fromView.addSubview(self)
    self.show()
    
  }
  
  
}

class WalletAddCardSheetContentView: UIView,UITextFieldDelegate {

  @IBOutlet weak var nameTf: UITextField!
  @IBOutlet weak var numberTf: UITextField!
  @IBOutlet weak var dateTf: UITextField!
  @IBOutlet weak var cvvTf: UITextField!
  var date:String?
  var confirmHandler:(((name:String,number:String,date:String,cvv:String,button:LoadingButton))->())?
  
  @IBOutlet weak var addButton: LoadingButton!
  override func awakeFromNib() {
    super.awakeFromNib()
    dateTf.isEnabled = false
    nameTf.delegate = self
    nameTf.returnKeyType = .done
    
    numberTf.delegate = self
    numberTf.keyboardType = .numberPad
    numberTf.returnKeyType = .done
    
    cvvTf.delegate = self
    cvvTf.keyboardType = .numberPad
    cvvTf.returnKeyType = .done
    
    addButton.backgroundColor = R.color.line()
    addButton.isEnabled = false
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  @IBAction func addCardAction(_ sender: LoadingButton) {
    if let name = nameTf.text,let number = numberTf.text,let date = self.date,let cvv = cvvTf.text {
      let tupple = (name:name,number:number,date:date,cvv:cvv,button:sender)
      self.confirmHandler?(tupple)
    }
    
  }
  @IBAction func dateSelectAction(_ sender: Any) {
    endEditing(true)
    DatePickerView.show(mode: .date) { date in
      let dateStr = date.string(withFormat: "MM/YY")
      self.date = date.string(withFormat: "yyyy-MM-dd")
      self.dateTf.text = dateStr
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    updateButtonStatus()
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    updateButtonStatus()
  }
  
  func updateButtonStatus() {
    if let name = nameTf.text,let number = numberTf.text,let date = dateTf.text,let cvv = cvvTf.text {
      if !name.isEmpty && !number.isEmpty && !date.isEmpty && !cvv.isEmpty {
        addButton.backgroundColor = R.color.theamRed()
        addButton.isEnabled = true
      }else {
        addButton.backgroundColor = R.color.line()
        addButton.isEnabled = false
      }
    }
  }
  
}
