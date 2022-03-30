//
//  FillInEnquiryFromSelectSubjectSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/24.
//

import UIKit

class FillInEnquiryFromSelectSubjectSheetView: UIView,UITableViewDataSource,UITableViewDelegate {

  private var titleLabel = UILabel().then { label in
    label.font = UIFont(.AvenirNextDemiBold,18)
    label.textColor = R.color.theamBlue()
    label.text = "Select Subjects"
  }
  private var tableView: UITableView!
  private var datas:[QuestionSubjectModel] = []
  private var selectComplete:((QuestionSubjectModel)->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(titleLabel)
    configTableview(.plain)
    getSubject()
  }
  
  func configTableview(_ style:UITableView.Style) {
    
    tableView = UITableView.init(frame: .zero, style: style)
    
    tableView?.delegate = self
    tableView?.dataSource = self
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = UIColor(hexString: "#E0E0E0")
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView?.backgroundColor = .white
    tableView?.showsHorizontalScrollIndicator = false
    tableView?.showsVerticalScrollIndicator = false
    tableView?.tableFooterView = UIView.init()
    
    tableView?.estimatedRowHeight = 0
    tableView?.estimatedSectionFooterHeight = 0
    tableView?.estimatedSectionHeaderHeight = 0
    //
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
    
    addSubview(tableView!)
    
    tableView?.contentInsetAdjustmentBehavior = .never
    tableView.register(cellWithClass: UITableViewCell.self)
    tableView.rowHeight = 50
  }
  
  func getSubject() {
    let params = SOAPParams(action: .HelpManager, path: .getAllSubjects)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decode([QuestionSubjectModel].self, from: data) else {
        return
      }
    
      self.datas = models
      self.tableView.reloadData()
    } errorHandler: { e in
      
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(24)
      make.centerX.equalToSuperview()
    }
    
    tableView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(24)
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    datas.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
    if datas.count > 0 {
      cell.textLabel?.textColor = R.color.black333()
      cell.textLabel?.font = UIFont(.AvenirNextRegular,16)
      cell.textLabel?.text = datas[indexPath.row].subject
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    selectComplete?(datas[indexPath.row])
    EntryKit.dismiss()
  }
  
  static func showView(complete:@escaping (QuestionSubjectModel)->()) {
    let view = FillInEnquiryFromSelectSubjectSheetView()
    view.selectComplete = complete
    let size = CGSize(width: kScreenWidth, height: kScreenHeight * 0.75)
    EntryKit.display(view: view, size: size, style: .sheet)
    
  }
}
