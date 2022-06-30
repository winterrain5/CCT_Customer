//
//  VerificationCodeContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit


enum SendVerificaitonCodeType {
  case LoginByMobile
  case LoginByEmail
  case SignUp
  case EditPhone
  case EditEmail
  case EditPassword
  case DeleteAccount
}


class VerificationCodeContainer: UIView {

  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var bottomLabel: TapLabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var resendLabel: UILabel!
  @IBOutlet weak var countDownButton: CountDownButton!
  @IBOutlet weak var inputBox: CRBoxInputView!
  var resendHandler:(()->())?
  var confirmHandler:((String?)->())?
  var source:String = ""
  var type:SendVerificaitonCodeType = .EditPhone {
    didSet {
      if type == .EditPhone || type == .LoginByMobile || type == .SignUp{
        titleLabel.text = "We have sent the verification code to +65 \(source)"
      }
      
      if type == .EditEmail {
        titleLabel.text = "We have sent the verification code to \(source)"
       
      }
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    
    inputBox.inputType = .number
    inputBox.resetCodeLength(4, beginEdit: false)
    
    inputBox.boxFlowLayout?.minimumInteritemSpacing = 8
    inputBox.boxFlowLayout?.minimumLineSpacing = 8
    inputBox.boxFlowLayout?.itemSize = CGSize(width: 75, height: 75)
    
    let property = CRBoxInputCellProperty()
    property.borderWidth = 1
    property.cellBgColorNormal = UIColor(hexString: "#FAF3EB")!
    property.cellBgColorFilled = UIColor(hexString: "#FAF3EB")!
    property.cellBgColorSelected = UIColor(hexString: "#FAF3EB")!
    property.cellBorderColorNormal = .clear
    property.cellBorderColorSelected = .clear
    property.cornerRadius = 16
    inputBox.customCellProperty = property
    
    inputBox.ifClearAllInBeginEditing = true
    
    inputBox.loadAndPrepare(withBeginEdit: false)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(resendCode))
    resendLabel.addGestureRecognizer(tap)
    
    let attr = NSMutableAttributedString(string: "Did not receive it? Resend Code")
    attr.addAttribute(.font, value: UIFont(name:.AvenirNextRegular,size:14), range: NSRange(location: 0, length: 20))
    attr.addAttribute(.foregroundColor, value: R.color.black333()!, range: NSRange(location: 0, length: 20))
    
    attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size:14), range: NSRange(location: 20, length: 11))
    attr.addAttribute(.foregroundColor, value: R.color.theamRed()!, range: NSRange(location: 20, length: 11))
    resendLabel.attributedText = attr
    
    inputBox.textEditStatusChangeblock = { [weak self] status in
      guard let `self` = self else { return }
      if status == .endEdit {
        if self.inputBox.textValue?.isEmpty ?? false {
          return
        }
        self.confirmHandler?(self.inputBox.textValue)
      }
    }

    bottomLabel.enabledTapAction = true
    bottomLabel.enabledTapEffect = false
    
    bottomLabel.yb_addAttributeTapAction(["Terms of Service and conditions","Privacy Policy"]) { str, range, idx in
      if idx == 0 {
        WalletTermsConditionsSheetView.show()
      }
      if idx == 1 {
        DataProtectionSheetView.show()
      }
    }
    
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    
  }
  
  func startCountDown() {
    countDownButtonAction(countDownButton)
  }
  
  @objc func resendCode() {
    countDownButtonAction(countDownButton)
    resendHandler?()
  }
  @objc func countDownButtonAction(_ sender: CountDownButton) {
    
    sender.startCountDownWithSecond(60)
    sender.countDownChange { (btn, second) -> String in
    "00:\(second)"
    }
    sender.countDownFinished { (btn, second) -> String in
    "00:00"
    }
  }

}
