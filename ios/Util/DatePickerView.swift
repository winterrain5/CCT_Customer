//
//  DatePickerView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit

class DatePickerView: UIView {

  @IBOutlet weak var datePicker: UIDatePicker!
  
  var completeHandler:((Date)->())?
  var dismissHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    datePicker.subviews.forEach { v in
      print("datepicker subview:\(v)")
    }
  }
  
  override func layoutSubviews() {
      super.layoutSubviews()
      corner(byRoundingCorners: [.topLeft,.topRight], radii: 20)
  }
  /// 显示日历组件
  /// - Parameters:
  ///   - mode: 日期显示模式
  ///   - date: 当前日期
  ///   - minimumDate: 最小日期
  ///   - maximumDate: 最大日期
  ///   - completeHandler: 选择完毕的回调
  /// - Returns: no returns
  static func show(mode: UIDatePicker.Mode,
                   date: Date? = Date(),
                   minimumDate: Date? = nil,
                   maximumDate: Date? = nil,
                   completeHandler:@escaping(Date)->()) {
      let view = DatePickerView.loadViewFromNib()
      view.datePicker.datePickerMode = mode
      view.datePicker.date = date ?? Date()
      view.datePicker.minimumDate = minimumDate
      view.datePicker.maximumDate = maximumDate
      
      if #available(iOS 13.4, *) {
          view.datePicker.preferredDatePickerStyle = .wheels
      } else {
          // Fallback on earlier versions
      }
      view.completeHandler = completeHandler
      let size = CGSize(width: kScreenWidth, height: 420)
      EntryKit.display(view: view, size: size, style: .sheet)
  }

  @IBAction func cancelAction(_ sender: Any) {
    dismissHandler?()
    EntryKit.dismiss()
  }
  @IBAction func confirmAction(_ sender: Any) {
    completeHandler?(datePicker.date)
    EntryKit.dismiss()
  }
}
