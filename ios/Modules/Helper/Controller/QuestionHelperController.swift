//
//  AskQuestionViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/24.
//

import UIKit
import IQKeyboardManagerSwift
class QuestionHelperController: BaseTableController {
  private var headerView = BlogHeaderSearchView.loadViewFromNib()
  
  private var sectionView = QuestionSegmentSectionView()
  private var subjectId:String = ""
  private var sendButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamBlue()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.titleForNormal = "Submit an enquiry"
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    IQKeyboardManager.shared.enable = true
    self.view.addSubview(sendButton)
    sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
    sendButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(32)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(40 + kBottomsafeAreaMargin)
    }
    getAllSubject()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    IQKeyboardManager.shared.enableAutoToolbar = false
  }
  @objc func sendButtonAction() {
    FillInEnquiryFormView.showView(from: self.view)
  }
  
  override func refreshData() {
    getAllHelpsContent()
  }
  
  func getAllSubject() {
    let params = SOAPParams(action: .HelpManager, path: .getAllSubjects)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decodeByCodable([QuestionSubjectModel].self, from: data) else {
        return
      }
    
      self.sectionView.tags = models
      
      self.subjectId = models.first?.id ?? ""
      self.loadNewData()
    } errorHandler: { e in
      
    }
    
  }
  
  func getAllHelpsContent() {
    let params = SOAPParams(action: .HelpManager, path: .getAllHelpsContent)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    if subjectId == "-1" {
      params.set(key: "subjectId", value: 0)
      params.set(key: "cctOrMp", value: 2)
    }else {
      params.set(key: "subjectId", value: subjectId)
      params.set(key: "cctOrMp", value: 0)
    }
    
    params.set(key: "limit", value: 0)
    NetworkManager().request(params: params) { data in
      self.updateData(data)
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }
    
  }
  
  func getHelpsByKeys(_ key:String) {
    let params = SOAPParams(action: .HelpManager, path: .getHelpsByKeys)
    params.set(key: "key", value: key)
    NetworkManager().request(params: params) { data in
      self.updateData(data)
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }
    
  }
  
  func updateData(_ data:Data) {
    guard let models = DecodeManager.decodeByCodable([QuestionAnswerModel].self, from: data) else {
      return
    }
    models.forEach { model in
      model.isExpend = false
      model.cellHeight = (model.title?.heightWithConstrainedWidth(width: kScreenWidth - 64, font: UIFont(.AvenirNextDemiBold,18)) ?? 0) + 42
    }
    self.dataArray = models
    self.endRefresh()
  }
  
  override func createListView() {
    super.createListView()
    
    self.tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: 126)
    headerView.title = "How can we help you?"
    headerView.placeholder = "Type Keywords"
    headerView.searchHandler = { [weak self] text in
      guard let `self` = self else { return }
      self.getHelpsByKeys(text)
    }
    
    
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84 + kBottomsafeAreaMargin, right: 0)

    tableView?.register(cellWithClass: QuestionFlexibleCell.self)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if dataArray.count == 0 { return 0 }
    let cellHeight = (dataArray[indexPath.row] as! QuestionAnswerModel).cellHeight ?? 0
    return cellHeight
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: QuestionFlexibleCell.self)
    if dataArray.count > 0 {
      cell.indexRow = indexPath.row
      cell.model = dataArray[indexPath.row] as? QuestionAnswerModel
      cell.expendHandler = { [weak self] model,row in
        self?.tableView?.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
      }
      cell.selectionStyle = .none
    }
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    sectionView.segmentDidClickHandler = { [weak self] model in
      guard let `self` = self else { return }
      self.subjectId = model.id ?? ""
      self.loadNewData()
    }
    return sectionView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 108
  }
  
}
