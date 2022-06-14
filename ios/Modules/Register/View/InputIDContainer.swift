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
  /// 1: Singapore NRIC/FIN 2:Foreign ID
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
    
    if let user = Defaults.shared.get(for: .userModel) {
      idTf.text = user.card_number
      idTypeButton.titleForNormal = "Singapore NRIC/FIN"
      selectIDType = 1
      setNextButonState()
    }
  
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
    setNextButonState()
  }
  
  @IBAction func nextAction(_ sender: Any) {
    if selectIDType == 1 {
      if let user = Defaults.shared.get(for: .userModel),!user.card_number.isEmpty,user.card_number.uppercased() == (idTf.text?.uppercased() ?? "") {
        next()
      }else {
        checkICExist()
      }
    }else {
      checkICExist()
    }
    
  }
  
  func checkICExist() {
    nextButon.startAnimation()
    
    let params = SOAPParams(action: .Client, path: .clientICExists)
    params.set(key: "IcNo", value: idTf.text ?? "")
    
    NetworkManager().request(params: params) { data in
      let data = String(data: data, encoding: .utf8)
      if data == "0" {
        self.next()
      }else {
        self.showErrorSheet()
      }
    } errorHandler: { e in
      self.nextButon.stopAnimation()
    }

  }
  
  func showErrorSheet() {
    let title = "You seem to have a  duplicate Identification No."
    let info = "Unable to proceed with registration, please approach our counter staff or call 62933933"
    let confirm = "Call now"
    AlertView.show(title: title, message: info, leftButtonTitle: "Cancle", rightButtonTitle: confirm, messageAlignment: .center) {
      
    } rightHandler: {
      CallUtil.call(with: "62933933")
    } dismissHandler: {
      
    }
    
    self.idTf.text = ""
    self.setNextButonState()
    self.nextButon.stopAnimation()
    

  }
  
  func next() {
    if let registInfo = Defaults.shared.get(for: .registModel) {
      registInfo.IcNum = idTf.text ?? ""
      Defaults.shared.set(registInfo, for: .registModel)
    }
    nextButon.stopAnimation()
    let vc = InputAccountController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
  }
  
  @IBAction func selectIDAction(_ sender: Any) {
    let dataArray = ["Singapore NRIC/FIN","Foreign ID"]
    BookingServiceFormSheetView.show(dataArray: dataArray, type: .SelectID) { idx in
      self.selectIDType = idx + 1
      self.idTypeButton.titleForNormal = dataArray[idx]
      self.setNextButonState()
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    setNextButonState()
  }
  
  func setNextButonState() {
    
    let text = idTf.text ?? ""
    
    if text.isEmpty {
      return
    }
    
    if selectIDType == 0 {
      AlertView.show(message: "Please select ID Type")
      return
    }
    
    var isValidate = true
    if selectIDType == 1 {
      isValidate = text.isNRICRuler()
      if !isValidate {
        AlertView.show(message: "The NRIC/FIN does not meet the requirements of Singapore. Please confirm it and input it.")
        return
      }
    }
    
    let isEnable = !isCheckButton.isSelected && isValidate && selectIDType != 0
    if isEnable {
      nextButon.isEnabled = true
      nextButon.backgroundColor = R.color.theamRed()
    }else {
      nextButon.isEnabled = false
      nextButon.backgroundColor = R.color.grayE0()
    }
  }
}
