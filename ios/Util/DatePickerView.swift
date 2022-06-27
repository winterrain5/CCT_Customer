//
//  DatePickerView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit

class DatePickerView: UIView {
  
  var datePicker = NTMonthYearPicker.init(frame: CGRect(x: 0, y: 16, width: kScreenWidth, height: 272))
  var completeHandler:((Date)->())?
  var dismissHandler:(()->())?
  override func awakeFromNib() {
    super.awakeFromNib()
    datePicker.datePickerMode = NTMonthYearPickerMode(rawValue: 0)
    datePicker.minimumDate = Date()
    addSubview(datePicker)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 20)
  }
  /// 显示添加信用有效期组件
  /// - Parameters:
  ///   - completeHandler: 选择完毕的回调
  /// - Returns: no returns
  static func show(completeHandler:@escaping(Date)->()) {
    let view = DatePickerView.loadViewFromNib()
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
