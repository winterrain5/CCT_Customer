//
//  DateOfBirthSheetView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/8.
//

import UIKit

class DatePickerSheetView: UIView {

  @IBOutlet weak var datePicker: UIDatePicker!
 
  var selectCompleteHalder:((Date)->())?
  var minDate:Date? {
    didSet {
      if let minDate = minDate {
        datePicker.minimumDate = minDate
      }
    }
  }
  var maxDate:Date? {
    didSet {
      if let maxDate = maxDate {
        datePicker.maximumDate = maxDate
      }
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
  
    if #available(iOS 13.4, *) {
      datePicker.preferredDatePickerStyle = .wheels
    } else {
      // Fallback on earlier versions
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func confirmAction(_ sender: Any) {
    EntryKit.dismiss()
    selectCompleteHalder?(datePicker.date)
  }
  
  @IBAction func cancelAction(_ sender: Any) {
    EntryKit.dismiss()
  }
  @IBAction func dateValueChangedAction(_ sender: UIDatePicker) {
    print(sender.date.dateString())
  }
  
  static func show(maximumDate:Date? = nil, minimumDate:Date? = nil, complete:@escaping (Date)->()) {
    let view = DatePickerSheetView.loadViewFromNib()
    view.maxDate = maximumDate
    view.minDate = minimumDate
    view.selectCompleteHalder = complete
    let size = CGSize(width: kScreenWidth, height: 400)
    EntryKit.display(view: view, size: size, style: .sheet)
  }
}
