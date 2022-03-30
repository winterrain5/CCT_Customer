//
//  VerificationCodeContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit

class VerificationCodeContainer: UIView {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var resendLabel: UILabel!
  @IBOutlet weak var confirmButton: LoadingButton!
  @IBOutlet weak var countDownButton: CountDownButton!
  @IBOutlet weak var inputBox: CRBoxInputView!
  var resendHandler:(()->())?
  var confirmHandler:((String?)->())?
  var source:String = ""
  var type:EditInfoType = .phone {
    didSet {
      if type == .phone {
        titleLabel.text = "We have sent the verification code to +65 \(source)"
      }
      
      if type == .email {
        titleLabel.text = " We have sent the verification code to \(source)"
       
      }
      
      if type == .pwd {
        
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
    attr.addAttribute(.font, value: UIFont(.AvenirNextRegular,14), range: NSRange(location: 0, length: 20))
    attr.addAttribute(.foregroundColor, value: R.color.black333()!, range: NSRange(location: 0, length: 20))
    
    attr.addAttribute(.font, value: UIFont(.AvenirNextDemiBold,14), range: NSRange(location: 20, length: 11))
    attr.addAttribute(.foregroundColor, value: R.color.theamRed()!, range: NSRange(location: 20, length: 11))
    resendLabel.attributedText = attr
    
    
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
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
  @IBAction func confirmButtonAction(_ sender: Any) {
    confirmHandler?(inputBox.textValue)
  }
}
