//
//  FeedbackFormContainer.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/22.
//

import UIKit

class FeedbackFormContainer: UIView,UITextFieldDelegate,TTGTextTagCollectionViewDelegate {
  
  @IBOutlet weak var q1ContentView: UIView!
  @IBOutlet weak var q1TagView: TTGTextTagCollectionView!
  @IBOutlet weak var q1Tf: UITextField!
  var q1Index:UInt?
  
  @IBOutlet weak var q2ContentView: UIView!
  @IBOutlet weak var q2TagView: TTGTextTagCollectionView!
  @IBOutlet weak var q2Tf: UITextField!
  var q2Index:UInt?
  
  @IBOutlet weak var q3ContentView: UIView!
  @IBOutlet weak var q3TagView: TTGTextTagCollectionView!
  @IBOutlet weak var q3Tf: UITextField!
  var q3Index:UInt?
  
  @IBOutlet weak var q4ContentView: UIView!
  @IBOutlet weak var q4TagView: TTGTextTagCollectionView!
  @IBOutlet weak var q4Tf: UITextField!
  var q4Index:UInt?
  
  @IBOutlet weak var q5ContentView: UIView!
  @IBOutlet weak var q5Tf: UITextField!
  
  @IBOutlet weak var submitButton: LoadingButton!
  var bookingTimeId:String = ""
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setup(q1ContentView, q1Tf, Array(1...5), q1TagView)
    setup(q2ContentView, q2Tf, Array(1...5), q2TagView)
    setup(q3ContentView, q3Tf, Array(1...5), q3TagView)
    setup(q4ContentView, q4Tf, Array(1...10),q4TagView)
    setup(q5ContentView, q5Tf)
  }
  
  func setup(_ shadow:UIView,_ tfDelegate:UITextField,_ tagMax:Array<Int> = [], _ tagView:TTGTextTagCollectionView? = nil) {
    let light:UIColor = UIColor(hexString: "#040000")!.withAlphaComponent(0.1)
    shadow.shadow(cornerRadius: 16, color: light, offset: CGSize(width: 0, height: 10), radius: 10, opacity: 1)
    
    tfDelegate.delegate = self
    
    tagMax.map({ $0.string }).forEach { [weak self] text in
      guard let `self` = self else { return }
      if tagView == self.q4TagView {
        self.addTags(text, CGSize(width: 28, height: 28), tagView)
      }else {
        self.addTags(text, CGSize(width: 44, height: 44), tagView)
      }
    }
    if tagView == self.q4TagView {
      tagView?.horizontalSpacing = (kScreenWidth - 80 - 10 * 28) / 9
    }else {
      tagView?.horizontalSpacing = (kScreenWidth - 80 - 5 * 44) / 4
    }
    tagView?.scrollView.isScrollEnabled = false
    tagView?.delegate = self
    tagView?.scrollDirection = .horizontal
    tagView?.contentInset = .zero
  }
  
  func addTags(_ text:String,_ size:CGSize, _ tagView:TTGTextTagCollectionView? = nil) {
    let content = TTGTextTagStringContent(text: text, textFont: UIFont(.AvenirNextDemiBold,16), textColor: R.color.black333())
    let style = TTGTextTagStyle()
    style.backgroundColor = R.color.placeholder()!
    style.cornerRadius = size.width * 0.5
    style.exactHeight = size.height
    style.extraSpace = .zero
    style.minWidth = size.width
    style.borderWidth = 0
    style.shadowColor = .clear
    
    let selectContent = TTGTextTagStringContent(text: text, textFont: UIFont(.AvenirNextDemiBold,16), textColor: .white)
    let selectedStyle = style.copy() as! TTGTextTagStyle
    selectedStyle.backgroundColor = R.color.theamBlue()!
    
    let tag = TTGTextTag(content: content, style: style, selectedContent: selectContent, selectedStyle: selectedStyle)
    tagView?.addTag(tag)
  }
  
  
  func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
    
    updateTag(textTagCollectionView, q1TagView, selIndex: &q1Index, index: index)
    updateTag(textTagCollectionView, q2TagView, selIndex: &q2Index, index: index)
    updateTag(textTagCollectionView, q3TagView, selIndex: &q3Index, index: index)
    updateTag(textTagCollectionView, q4TagView, selIndex: &q4Index, index: index)
    
  }
  
  func updateTag(_ textTagCollectionView:TTGTextTagCollectionView, _ selTagView:TTGTextTagCollectionView, selIndex:inout UInt?, index:UInt) {
    if textTagCollectionView == selTagView {
      if let sel = selIndex {
        selTagView.updateTag(at: sel, selected: false)
      }
      selTagView.updateTag(at: index, selected: true)
      selIndex = index
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing(true)
    return true
  }
  
  @IBAction func submitButtonAction(_ sender: LoadingButton) {
    let params = SOAPParams(action: .Sale, path: .saveServiceReview)
    params.set(key: "bookingTimeId", value: bookingTimeId)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    let data = SOAPDictionary()
    data.set(key: "store_experience_rating", value: q1Index ?? 0 + 1)
    data.set(key: "store_experience_reason", value: q1Tf.text ?? "")
    
    data.set(key: "customer_service_rating", value: q2Index ?? 0 + 1)
    data.set(key: "customer_service_reason", value: q2Tf.text ?? "")
    
    data.set(key: "want_service_rating", value: q3Index ?? 0 + 1)
    data.set(key: "want_service_reason", value: q3Tf.text ?? "")
    
    data.set(key: "recommend_rating", value: q4Index ?? 0 + 1)
    data.set(key: "recommend_reason", value: q4Tf.text ?? "")
    
    data.set(key: "other_feedback", value: q5Tf.text ?? "")
    
    params.set(key: "data", value: data.result, type: .map(1))
    
    sender.startAnimation()
    NetworkManager().request(params: params) { data in
      sender.stopAnimation()
      Toast.showSuccess(withStatus: "Submit Successful")
      UIViewController.getTopVc()?.navigationController?.popViewController()
    } errorHandler: { e in
      sender.stopAnimation()
    }

    
  }
}
