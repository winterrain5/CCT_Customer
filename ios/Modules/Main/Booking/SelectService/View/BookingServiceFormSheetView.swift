//
//  BookingServiceFormSheetView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/23.
//

import UIKit
enum SheetType {
  case Outlet
  case Service
  case TimeSlot
  case Therapist
  case SelectID
  case SelectCountry
}
extension SheetType {
  var title:String {
    switch self {
    case .Outlet:
      return "Select Outlet"
    case .Service:
      return "Select Service"
    case .TimeSlot:
      return "Select Time Slot"
    case .Therapist:
      return "Select Therapist"
    case .SelectID:
      return "Select ID Type"
    case .SelectCountry:
      return "Select Country"
    }
  }
}
class BookingServiceFormSheetView: UIView,UITableViewDelegate,UITableViewDataSource {
 
  
  var titleLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 18)
  }
  var lineLayer = CAShapeLayer().then { layer in
    layer.backgroundColor = R.color.grayf2()?.cgColor
  }
  var dataArray:[Any] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  var type:SheetType = .Outlet {
    didSet {
      titleLabel.text = type.title
    }
  }
  var selectComplete:((Int)->())?
  var tableView:UITableView!
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(titleLabel)
    layer.addSublayer(lineLayer)
    setupTableView()
  }
  
  func setupTableView() {
    
    tableView = UITableView(frame: .zero, style: .plain)
    addSubview(tableView)
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .singleLine
    tableView.separatorColor = R.color.grayf2()
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    
    tableView.register(cellWithClass: UITableViewCell.self)
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
    tableView.snp.makeConstraints { make in
      make.bottom.left.right.equalToSuperview()
      make.top.equalToSuperview().offset(88)
    }
    lineLayer.frame = CGRect(x: 0, y: 68, width: kScreenWidth, height: 1)
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
    
    if dataArray.count > 0 {
      let data = dataArray[indexPath.row]
      cell.textLabel?.font = UIFont(name: .AvenirNextRegular, size: 14)
      if data is String {
        cell.textLabel?.text = data as? String
        cell.textLabel?.textColor = R.color.black333()
      }
      if data is EmployeeForServiceModel {
        let model =  (data as? EmployeeForServiceModel)
        cell.textLabel?.text = model?.employee_name
        if model?.gender == 1 {
          cell.imageView?.image = R.image.booking_user()
          cell.textLabel?.textColor = kManFontColor
        }else {
          cell.imageView?.image = R.image.woman()
          cell.textLabel?.textColor = kWomanFontColor
        }
      }
      
      cell.textLabel?.numberOfLines = 0
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    selectComplete?(indexPath.row)
    EntryKit.dismiss()
  }
  
  private static func show(dataArray:[Any],type:SheetType,selectComplete:@escaping (Int)->()) {
    let view = BookingServiceFormSheetView()
    view.dataArray = dataArray
    view.type = type
    view.selectComplete = selectComplete
    
    let height = (dataArray.count * 50 + 92) > (kScreenHeight * 0.7).int ? Int(kScreenHeight * 0.7) : (dataArray.count * 50 + 92)
    let size = CGSize(width: kScreenWidth, height: height.cgFloat + kBottomsafeAreaMargin + 40)
    EntryKit.displayView(asSheet: view, size: size)
  }
  static func show(dataArray:[EmployeeForServiceModel],type:SheetType,selectComplete:@escaping (Int)->()) {
    self.show(dataArray: dataArray as [Any], type: type, selectComplete: selectComplete)
  }
  static func show(dataArray:[String],type:SheetType,selectComplete:@escaping (Int)->()) {
    self.show(dataArray: dataArray as [Any], type: type, selectComplete: selectComplete)
  }
}


