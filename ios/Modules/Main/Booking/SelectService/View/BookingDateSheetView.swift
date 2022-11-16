//
//  BookingDateSheetView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/23.
//

import UIKit

class BookingDateSheetView: UIView{
  
  var titleLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 18)
    label.text = "Select Date"
  }
  var lineLayer = CAShapeLayer().then { layer in
    layer.backgroundColor = R.color.grayf2()?.cgColor
  }
  var monthLabel = UILabel().then { label in
    label.textColor = R.color.black333()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 18)
  }
  var leftButton = UIButton().then { btn in
    btn.imageForNormal = R.image.booking_calendar_left()
  }
  var rightButton = UIButton().then { btn in
    btn.imageForNormal = R.image.booking_calendar_right()
  }
  lazy var calendar = FSCalendar().then { view in
    view.dataSource = self
    view.delegate = self
  }
  
  var gregorian = NSCalendar(identifier: .gregorian)
  
  var dataArray:[String] = [] {
    didSet {
      calendar.reloadData()
    }
  }
  
  var selectComplete:((Date)->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(titleLabel)
    layer.addSublayer(lineLayer)
    addSubview(monthLabel)
    addSubview(leftButton)
    addSubview(rightButton)
    
    leftButton.addTarget(self, action: #selector(leftButtonAction), for: .touchUpInside)
    rightButton.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
    
    setupCalendar()
  }
  
  func setupCalendar() {
    
    addSubview(calendar)
    
    let currentDate = Date()
    calendar.appearance.selectionColor = R.color.theamRed()
    calendar.appearance.titleDefaultColor = R.color.black333()
    calendar.appearance.titleFont = UIFont(name: .AvenirNextRegular, size: 16)
    calendar.appearance.caseOptions = .weekdayUsesUpperCase
    calendar.appearance.eventDefaultColor = .clear
    calendar.scope = .month
    calendar.appearance.borderRadius = 1
    calendar.rowHeight = (kScreenWidth - 36) / 7
    calendar.placeholderType = .none
    calendar.headerHeight = 0
    calendar.appearance.weekdayFont = UIFont(name: .AvenirNextDemiBold, size: 12)
    calendar.appearance.weekdayTextColor = R.color.grayBD()
    calendar.firstWeekday = 2
    calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
    calendar.today = nil
    monthLabel.text = currentDate.string(withFormat: "MMMM")
    
  }
  
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(24)
      make.height.equalTo(28)
    }
    
    lineLayer.frame = CGRect(x: 0, y: 68, width: kScreenWidth, height: 1)
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    
    calendar.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(18)
      make.top.equalToSuperview().offset(130)
      make.bottom.equalToSuperview().offset(-(kBottomsafeAreaMargin + 20))
    }
    
    monthLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(85)
      make.height.equalTo(28)
    }
    leftButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.width.height.equalTo(24)
      make.centerY.equalTo(monthLabel)
    }
    rightButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.width.height.equalTo(24)
      make.centerY.equalTo(monthLabel)
    }
  }
  
  @objc func leftButtonAction() {
    let unit:NSCalendar.Unit = .month
    guard let prevPage = self.gregorian?.date(byAdding: unit, value: -1, to: self.calendar.currentPage, options: []) else { return }
    self.calendar.setCurrentPage(prevPage, animated: true)
  }
  
  @objc func rightButtonAction() {
    let unit:NSCalendar.Unit = .month
    guard let nextPage = self.gregorian?.date(byAdding: unit, value: 1, to: self.calendar.currentPage, options: []) else { return }
    self.calendar.setCurrentPage(nextPage, animated: true)
  }
  
  static func show(dataArray:[String],selectComplete:@escaping (Date)->()) {
    let view = BookingDateSheetView()
    view.dataArray = dataArray
    view.selectComplete = selectComplete
    
    let size = CGSize(width: kScreenWidth, height: 405)
    EntryKit.displayView(asSheet: view, size: size)
  }
  
}

extension BookingDateSheetView:FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance {
  
  func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
    let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
    return cell
  }
  
  
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    let date = calendar.currentPage
    monthLabel.text = date.string(withFormat: "MMMM")
  }
  
  func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
    if dataArray.map({ $0.date ?? Date() }).contains(date) {
      return true
    }
    return false
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
    if dataArray.map({ $0.date ?? Date() }).contains(date) {
      return R.color.black333()
    }
    return R.color.gray82()
  }
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    EntryKit.dismiss()
    selectComplete?(date)
  }
  
  
}



