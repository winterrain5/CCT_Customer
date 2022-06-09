//
//  InputIDContainer.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/7.
//

import UIKit

class InputIDContainer: UIView ,UITextFieldDelegate{
  @IBOutlet weak var infoContentView: UIView!
  
  @IBOutlet weak var idTypeButton: UIButton!
  @IBOutlet weak var idTf: UITextField!
  @IBOutlet weak var dataPNLabel: TapLabel!
  @IBOutlet weak var dataPN2Label: TapLabel!
  @IBOutlet weak var nextButon: LoadingButton!
  
  @IBOutlet weak var isCheckButton: UIButton!
  /// 0: Singapore NRIC/FIN 1:Foreign ID
  var selectIDType =  0
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(dataPNTaped))
    let tap2 = UITapGestureRecognizer(target: self, action: #selector(dataPNTaped))
    dataPNLabel.addGestureRecognizer(tap)
    dataPN2Label.addGestureRecognizer(tap2)
    
    idTf.delegate = self
    idTf.returnKeyType = .done
    
    isCheckButton.borderColor = .clear
  
  }
  
  @objc func dataPNTaped() {
    DataProtectionSheetView.show()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    infoContentView.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  @IBAction func isCheckAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      sender.imageForNormal = R.image.symptom_check_box_unselect()
      sender.backgroundColor = R.color.grayE0()
      sender.borderColor = UIColor(hexString: "777777")
    }else {
      sender.borderColor = .clear
      sender.imageForNormal = R.image.symptom_check_box_select()
    }
    setNextButonState(!sender.isSelected && !(idTf.text?.isEmpty ?? false))
  }
  
  @IBAction func nextAction(_ sender: Any) {
    let vc = InputAccountController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
  }
  
  @IBAction func selectIDAction(_ sender: Any) {
    let dataArray = ["Singapore NRIC/FIN","Foreign ID"]
    BookingServiceFormSheetView.show(dataArray: dataArray, type: .SelectID) { idx in
      self.selectIDType = idx
      self.idTypeButton.titleForNormal = dataArray[idx]
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    let text = textField.text ?? ""
    let isValidate = text.isNRICRuler()
    if !isValidate {
      AlertView.show(message: "The NRIC/FIN does not meet the requirements of Singapore. Please confirm it and input it.")
      return
    }
    setNextButonState(!isCheckButton.isSelected && !text.isEmpty && isValidate)
    
    
  }
  
  func setNextButonState(_ isEnable:Bool) {
    if isEnable {
      nextButon.isEnabled = true
      nextButon.backgroundColor = R.color.theamRed()
    }else {
      nextButon.isEnabled = false
      nextButon.backgroundColor = R.color.grayE0()
    }
  }
}
