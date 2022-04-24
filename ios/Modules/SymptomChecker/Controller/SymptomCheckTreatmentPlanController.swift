//
//  SymptomCheckTreatmentPlanController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/17.
//

import UIKit

class SymptomCheckTreatmentPlanController: BaseTableController {
  private var headerView = SymptomCheckPlanHeaderView.loadViewFromNib()
  private var reportId:String = ""
  private var model:SymptomCheckPlanModel?
  private lazy var footerView = UIView().then { view in
    view.backgroundColor = .white
    
    let btn = UIButton()
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.titleForNormal = "Book an Appointment"
    btn.titleColorForNormal = R.color.white()
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.addTarget(self, action: #selector(bookAppointmentAction), for: .touchUpInside)
    btn.frame = CGRect(x: 16, y: 12, width: kScreenWidth - 32, height: 44)
    view.addSubview(btn)
  }

  init(reportId:String) {
    super.init(nibName: nil, bundle: nil)
    self.reportId = reportId
  }
  
  init(model:SymptomCheckPlanModel) {
    super.init(nibName: nil, bundle: nil)
    self.model = model
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.bar.alpha = 0
    self.barAppearance(tintColor: .white,barBackgroundColor: .clear, image: R.image.return_left())
    self.view.backgroundColor = R.color.theamBlue()
    refreshData()
  }
  
  @objc func bookAppointmentAction() {
    SelectTypeOfServiceSheetView.show()
  }
  
  override func refreshData() {
    if let model = self.model {
      self.headerView.model = model
      self.endRefresh()
      return
    }
    let params = SOAPParams(action: .SymptomCheck, path: .getTreatmentPlanData)
    params.set(key: "reportId", value: reportId)
    NetworkManager().request(params: params) { data in
      guard let model = DecodeManager.decodeByCodable([SymptomCheckPlanModel].self, from: data) else {
        return
      }
      self.model = model.first
      self.headerView.model = model.first
      self.endRefresh()
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
    }
  }
  
  override func createListView() {
    super.createListView()
    tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: kScreenHeight)
    headerView.updateComplete = { [weak self] height in
      self?.headerView.height = height
      self?.tableView?.tableHeaderView = self?.headerView
    }
    
    tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 68)
    
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin, right: 0)
    tableView?.backgroundColor = .white
    tableView?.bounces = false
    tableView?.register(nibWithCellClass: SymptomCheckPlanCell.self)
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 100
    
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: SymptomCheckPlanCell.self)
    self.model?.type = indexPath.row
    cell.model = self.model
    cell.selectionStyle = .none
    return cell
  }
}
