//
//  WalletAddUserSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2023/7/10.
//

import UIKit
import IQKeyboardManagerSwift


class WalletAddUserSheetContentView: UIView,UITextFieldDelegate {
  
  
  @IBOutlet weak var emailTf: UITextField!
  @IBOutlet weak var confirmButton: LoadingButton!
  var confirmHandler:((String)->())?
  var cancelHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    
    emailTf.returnKeyType = .done
    emailTf.delegate = self
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  @IBAction func confirmButtonAction(_ sender: Any) {
    confirmHandler?(emailTf.text ?? "")
  }
  
  @IBAction func concelButtonAction(_ sender: Any) {
    cancelHandler?()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  
}


class WalletAddUserSheetView: UIView {

  var contentView = WalletAddUserSheetContentView.loadViewFromNib()
  let contentHeight:CGFloat = 520
  var scrolview = UIScrollView()
  var confirmHandler:((String)->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
    
    addSubview(scrolview)
    
    scrolview.addSubview(contentView)
    contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: contentHeight)
    contentView.confirmHandler = { [weak self] text in
      guard let `self` = self else { return }
      self.confirmHandler?(text)
    }
    contentView.cancelHandler = { [weak self] in
      self?.dismiss()
    }
  

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
  
  
  static func show(fromView:UIView,confirmHandler:@escaping (String)->()) {
    
    let view = WalletAddUserSheetView()
    view.frame = fromView.bounds
    view.confirmHandler = confirmHandler
    fromView.addSubview(view)
    view.show()
    
  }

}
