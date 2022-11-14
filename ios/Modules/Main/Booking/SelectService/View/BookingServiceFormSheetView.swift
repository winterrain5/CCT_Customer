//
//  BookingServiceFormSheetView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/23.
//

import UIKit
import SwiftEntryKit
class BookingServiceFormSheetView: UIView,UITableViewDelegate,UITableViewDataSource {
  enum SheetType {
    case Outlet
    case Service
    case TimeSlot
    case Therapist
    case SelectID
    case SelectCountry
  }
  var titleLabel = UILabel().then { label in
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 18)
  }
  var lineLayer = CAShapeLayer().then { layer in
    layer.backgroundColor = R.color.grayf2()?.cgColor
  }
  var dataArray:[String] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  var type:SheetType = .Outlet {
    didSet {
      switch type {
      case .Outlet:
        titleLabel.text = "Select Outlet"
      case .Service:
        titleLabel.text = "Select Service"
      case .TimeSlot:
        titleLabel.text = "Select Time Slot"
      case .Therapist:
        titleLabel.text = "Select Therapist"
      case .SelectID:
        titleLabel.text = "Select ID Type"
      case .SelectCountry:
        titleLabel.text = "Select Country"
      }
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
      let str = dataArray[indexPath.row]
      cell.textLabel?.font = UIFont(name: .AvenirNextRegular, size: 14)
      cell.textLabel?.text = str
      cell.textLabel?.textColor = R.color.black333()
      cell.textLabel?.numberOfLines = 0
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    selectComplete?(indexPath.row)
    SwiftEntryKit.dismiss()
  }
  
  static func show(dataArray:[String],type:SheetType,selectComplete:@escaping (Int)->()) {
    let view = BookingServiceFormSheetView()
    view.dataArray = dataArray
    view.type = type
    view.selectComplete = selectComplete
    
    let height = (dataArray.count * 50 + 92) > (kScreenHeight * 0.7).int ? Int(kScreenHeight * 0.7) : (dataArray.count * 50 + 92)
    let size = CGSize(width: kScreenWidth, height: height.cgFloat + kBottomsafeAreaMargin + 40)
    SwiftEntryKit.displayView(asSheet: view, size: size)
  }
}
