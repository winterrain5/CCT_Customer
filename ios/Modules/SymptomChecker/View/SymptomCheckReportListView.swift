//
//  SymptomCheckReportListView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/14.
//

import UIKit

class SymptomCheckReportListView: UIView ,UITableViewDelegate,UITableViewDataSource {
  private var tableView:UITableView?
  private var headerLabel = UILabel().then { label in
    label.font = UIFont(name: .AvenirNextDemiBold, size:18)
    label.lineHeight = 24
    label.textColor = R.color.theamBlue()
    label.text = "Previous Analysis Report"
  }
  private var emptyString:String = "No Analysis Report"
  private var shouldDisplay:Bool = false
 
  var datas:[SymptomCheckReportModel] = []
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(headerLabel)
    configTableview(.plain)
    loadData()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    headerLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(24)
    }
    tableView?.snp.makeConstraints({ make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(headerLabel.snp.bottom).offset(24)
    })
  }
  
  func loadData() {
    Toast.showLoading()
    let params = SOAPParams(action: .SymptomCheck, path: .getSymptomCheckReports)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "start", value: 1)
    params.set(key: "length", value: 1000)
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decodeByCodable([SymptomCheckReportModel].self, from: data) else {
        return
      }
      self.shouldDisplay = models.count == 0
      self.datas = models
      self.tableView?.reloadData()
      self.tableView?.reloadEmptyDataView()
      Toast.dismiss()
    } errorHandler: { error in
      self.emptyString = error.asAPIError.errorInfo().message
      self.shouldDisplay = true
      self.tableView?.reloadData()
      self.tableView?.reloadEmptyDataView()
    }

  }
  
  func configTableview(_ style:UITableView.Style) {
    
    tableView = UITableView.init(frame: .zero, style: style)
    
    tableView?.delegate = self
    tableView?.dataSource = self
    
    tableView?.separatorStyle = .none
    tableView?.backgroundColor = .white
    tableView?.showsHorizontalScrollIndicator = false
    tableView?.showsVerticalScrollIndicator = false
    tableView?.tableFooterView = UIView.init()
    tableView?.estimatedSectionFooterHeight = 0
    tableView?.estimatedSectionHeaderHeight = 0
    headerLabel.size = CGSize(width: kScreenWidth, height: 80)
    //
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 120
    addSubview(tableView!)
    
    tableView?.register(nibWithCellClass: SymptomCheckReportCell.self)
    tableView?.emptyDataView({ view in
      view.shouldFadeIn(true)
      view.shouldDisplay(self.shouldDisplay)
      view.titleLabelString(self.emptyTitle())
    })
  }
  
  func emptyTitle() -> NSMutableAttributedString  {
    let attributes:[NSAttributedString.Key:AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 14),NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.gray]
    
    return NSMutableAttributedString.init(string: emptyString, attributes: attributes)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return datas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: SymptomCheckReportCell.self)
    cell.selectionStyle = .none
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
    }
    cell.deleteHandler = { [weak self] model in
      UIViewController.getTopVc()?.showAlert(title: "Are you sure you want to delete this report", message: "You won’t be able to retrieve it", buttonTitles: ["Cancel","Confirm"], highlightedButtonIndex: 0, completion: { id in
        if id == 1 {
          Toast.showLoading()
          let params = SOAPParams(action: .SymptomCheck, path: .deleteSymptomReportById)
          params.set(key: "id", value: model.id ?? "")
          NetworkManager().request(params: params) { data in
            Toast.dismiss()
            self?.loadData()
          } errorHandler: { e in
            Toast.dismiss()
          }
        }
      })
     
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    EntryKit.dismiss {
      let vc = SymptomCheckReportAnalysisController(listModel: self.datas[indexPath.row])
      UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
    }
  }
  
  static func show() {
    let view = SymptomCheckReportListView()
    let size = CGSize(width: kScreenWidth, height: kScreenHeight - 150)
    EntryKit.display(view: view, size: size, style: .sheet)
  }
}
