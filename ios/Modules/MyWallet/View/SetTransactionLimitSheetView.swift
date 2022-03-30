//
//  SetTransactionLimitSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/9.
//

import UIKit

class SetTransactionLimitSheetView: UIView {

  @IBOutlet weak var noLimitButton: UIButton!
  @IBOutlet weak var limitAmountButton: UIButton!


  var limitTypeSelectButton:UIButton!
  var limitAmoutSelectButton:UIButton?
  @IBOutlet weak var limitAmountLabel: UILabel!
  @IBOutlet weak var limit3Button: UIButton!
  @IBOutlet weak var limit5Button: UIButton!
  @IBOutlet weak var limit7Button: UIButton!
  @IBOutlet weak var limit10Button: UIButton!
  var amount:[String] = ["300.00","500.00","700.00","1000.00"]
  
  var isNoLimit:Bool = false
  
  var cardUserModel:CardOwnerModel! {
    didSet {
      if (cardUserModel.trans_limit?.float() ?? 0) < 0 {
        isNoLimit = true
        limitTypeSelectButton = noLimitButton
        limitTypeButtonAction(noLimitButton)
      }else {
        isNoLimit = false
        limitTypeSelectButton = limitAmountButton
        limitTypeButtonAction(limitAmountButton)
        let limit = cardUserModel.trans_limit?.float()?.int ?? 0
        limitAmountLabel.text = "$" + limit.string
        
        if limit == 300 {
          limitAmoutSelectButton = limit3Button
          limitAmoutButtonAction(limit3Button)
        }
        
        if limit == 500 {
          limitAmoutSelectButton = limit5Button
          limitAmoutButtonAction(limit5Button)
        }
        
        if limit == 700 {
          limitAmoutSelectButton = limit7Button
          limitAmoutButtonAction(limit7Button)
        }
        
        if limit == 1000 {
          limitAmoutSelectButton = limit10Button
          limitAmoutButtonAction(limit10Button)
        }
        
      }
      
    }
  }
  var updateCompleteHandler:((CardOwnerModel)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func limitAmoutButtonAction(_ sender: UIButton) {
    
    if isNoLimit { return }
    
    if let sel = limitAmoutSelectButton {
      sel.isSelected = false
    }
    
    sender.isSelected.toggle()
    
    if sender.isSelected {
      sender.backgroundColor = R.color.theamBlue()
      sender.titleColorForNormal = .white
      
      if let sel = limitAmoutSelectButton,sel != sender {
        sel.backgroundColor = R.color.grayf2()
        sel.titleColorForNormal = .black
      }
      
    }else {
      sender.backgroundColor = R.color.grayf2()
      sender.titleColorForNormal = .black
    }
    
    limitAmountLabel.text = "$" + amount[sender.tag]
    
    limitAmoutSelectButton = sender
  }
  @IBAction func limitTypeButtonAction(_ sender: UIButton) {
    
    limitTypeSelectButton.isSelected = false
    sender.isSelected.toggle()
    
    isNoLimit = sender.tag == 0
    
    limitTypeSelectButton = sender
  }
  @IBAction func doneButton(_ sender: LoadingButton) {
    
    let params = SOAPParams(action: .Voucher, path: .setCardFriendLimit)
    params.set(key: "id", value: cardUserModel.id ?? "")
    var transLimit:Int = -1
    if !isNoLimit {
      if let sel = limitAmoutSelectButton {
        transLimit = amount[sel.tag].float()?.int ?? 0
      }
    }
   
    params.set(key: "transLimit", value: transLimit)
    sender.startAnimation()
    NetworkManager().request(params: params) { data in
      sender.stopAnimation()
      self.cardUserModel.trans_limit = transLimit.string.appending(".00")
      self.updateCompleteHandler?(self.cardUserModel)
      EntryKit.dismiss()
    } errorHandler: { e in
      sender.stopAnimation()
    }

    
  }
  
  
  /// display a view
  /// - Parameter cardUserModel: 卡信息
  static func show(cardUserModel:CardOwnerModel,complete:@escaping (CardOwnerModel)->()) {
    let view = SetTransactionLimitSheetView.loadViewFromNib()
    view.cardUserModel = cardUserModel
    view.updateCompleteHandler = complete
    let size = CGSize(width: kScreenWidth, height: 483 + kBottomsafeAreaMargin)
    EntryKit.display(view: view, size: size, style: .sheet)
  }
}
