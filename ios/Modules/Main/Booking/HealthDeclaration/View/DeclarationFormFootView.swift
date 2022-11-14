//
//  DeclarationFormFootView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit

class DeclarationFormFootView: UIView {
  @IBOutlet weak var termsLabel: TapLabel!
  @IBOutlet weak var isCheckButton: UIButton!
  @IBOutlet weak var nextButon: LoadingButton!
  var confirmHander:((LoadingButton)->())?
  // 1.保健 2.治疗 3.产前，4.产后
  var healthDeclarationType:String? {
    didSet {
      var terms:String = ""
      guard let healthDeclarationType = healthDeclarationType?.int else {
        return
      }
      
      if healthDeclarationType == 1 {
        terms = "I verify I have stated all my known medical conditions. I understand that I will be receiving massage therapy for stress reduction, muscle relief, or improving circulation and energy flow. I understand that the massage therapist does not diagnose illnesses. As such, she also does not prescribe medical treatment or medications. I also understand that she does not perform spinal manipulations. I am aware that this massage is not a substitute for medical examination or diagnosis,and that it is recommended that I see a physician for any ailment that I might have I understand and agree that I am receiving massage therapy entirely at my own risk.In the event that I become injured either directly or indirectly as a result, in whole or in part, of the aforesaid message therapy.I HEREBY INDEMNIFY the therapist, her principles, and company from all claims and liability whatsoever.\nI acknowledge that the above information given by me is compete and accurate to the best of my knowledge and that no fact that is likely to influence the safety of the treatment(s) that I have signup up for have been withheld."
      }
      
      if healthDeclarationType == 2 {
        terms = "I am willing to provide my practitioner with the information necessary for them to fully understand my medical history,presenting symptoms and the health goals I wish to achieve. I thereby consent to a thorough case history and Traditional Chinese Medicine diagnosis. I understand the methods of treatment may include but are not limited to: acupuncture, moxibustion,cupping, electrical stimulation, Tui Na(massage), and Chinese herbal medicine.I understand that it is my responsibility to inform the practitioner of all current medications, herbs and supplements that I take, as they may affect the treatment plan.I understand and agree that I am treatment and/or massage entirely at my own risk.In the event that I become injured either directly or indirectly as a result, in whole or in part, of the aforesaid. I HEREBY INDEMNIFY the Physican, therapist, her principles,and company from all claims and liability whatsoever.\nI acknowledge that the above information given by me is compete and accurate to the best of my knowledge and that no fact that is likely to influence the safety of the treatment(s) that I have signup up for have been withheld."
      }
      
      if healthDeclarationType == 3 {
        terms = "I verify that I am not having a high-risk pregnancy and I have stated all my known medical conditions. I understand that I will be receiving massage therapy for stress reduction, muscle relief, or improving circulation and energy flow. I understand that the massage therapist does not diagnose illnesses. As such, she also does not prescribe medical treatment or medications. I also understand that she does not perform spinal manipulations. I am aware that this massage is not a substitute for medical examination or diagnosis, and that it is recommended that I see a physician for any ailment that I might have. I understand and agree that I am receiving massage therapy entirely at my own risk. In the event that I become injured either directly or indirectly as a result, in whole or in part, of the aforesaid massage therapy. I HEREBY INDEMNIFY the therapist, her principles, and company from all claims and liability whatsoever.\nI acknowledge that the above information given by me is compete and accurate to the best of my knowledge and that no fact that is likely to influence the safety of the treatment(s) that I have signup up for have been withheld."
      }
      
      if healthDeclarationType ==   4 {
        terms = "I verify I have stated all my known medical conditions. I understand that I will be receiving massage therapy for stress reduction, muscle relief, or improving circulation and energy flow. I understand that the massage therapist does not diagnose illnesses. As such, she also does not prescribe medical treatment or medications. I also understand that she does not perform spinal manipulations. I am aware that this massage is not a substitute for medical examination or diagnosis, and that it is recommended that I see a physician for any ailment that I might have. I understand and agree that I am receiving massage therapy entirely at my own risk. In the event that I become injured either directly or indirectly as a result, in whole or in part, of the aforesaid message therapy. I HEREBY INDEMNIFY the therapist, her principles, and company from all claims and liability whatsoever.\nI acknowledge that the above information given by me is compete and accurate to the best of my knowledge and that no fact that is likely to influence the safety of the treatment(s) that I have signup up for have been withheld."
      }
      if healthDeclarationType == 5 {
        terms = "I acknowledge that the above child's information given by me is complete and accurate to the best of my knowledge and that no fact that is likely to influence the safety of the treatments) that I have signed up for my child has been withheld. \nConfidentiality Note: The information provided in the health questionnaire is for the sole purpose of carrying out safe and effective treatments) and will be kept strictly confidential. \nI declared that my child's health condition had remained unchanged, as stated in this health questionnaire."
      }
      termsLabel.text = terms
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    isCheckButton.imageForNormal = R.image.symptom_check_box_unselect()
    isCheckButton.tintColor = R.color.grayE0()
    isCheckButton.borderColor = UIColor(hexString: "777777")
    setNextButonState(isEnable: false)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  @IBAction func isCheckAction(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      sender.borderColor = .clear
      sender.tintColor = R.color.white()
      sender.imageForNormal = R.image.symptom_check_box_select()
    }else {
      sender.imageForNormal = R.image.symptom_check_box_unselect()
      sender.tintColor = R.color.grayE0()
      sender.borderColor = UIColor(hexString: "777777")
     
    }
    
    setNextButonState(isEnable: sender.isSelected)
  }
  
  
  @IBAction func nextAction(_ sender: Any) {
    confirmHander?(nextButon)
  }

  
  func setNextButonState(isEnable:Bool) {
   
    if isEnable {
      nextButon.isEnabled = true
      nextButon.backgroundColor = R.color.theamRed()
    }else {
      nextButon.isEnabled = false
      nextButon.backgroundColor = R.color.grayE0()
    }
  }
}
