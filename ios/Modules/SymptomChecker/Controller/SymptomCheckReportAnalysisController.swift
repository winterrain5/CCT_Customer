//
//  SymptomCheckReportAnalysisController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/14.
//

import UIKit
import PromiseKit
class SymptomCheckReportAnalysisController: BaseTableController {
  private var headerView = SymptomCheckDetailHeaderView.loadViewFromNib()
  private var result:[[SymptomCheckStepModel]] = []
  private lazy var footerView = UIView().then { view in
    view.backgroundColor = .white
    
    let helpButton = UIButton()
    helpButton.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    helpButton.titleForNormal = "How we can help you"
    helpButton.titleColorForNormal = R.color.white()
    helpButton.cornerRadius = 22
    helpButton.backgroundColor = R.color.theamBlue()
    helpButton.addTarget(self, action: #selector(helpButtonAction), for: .touchUpInside)
    helpButton.frame = CGRect(x: 16, y: 12, width: kScreenWidth - 32, height: 44)
    view.addSubview(helpButton)
    
    let emailMeButton = UIButton()
    emailMeButton.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    emailMeButton.titleForNormal = "Email me this report"
    emailMeButton.titleColorForNormal = R.color.theamRed()
    emailMeButton.backgroundColor = R.color.white()
    emailMeButton.addTarget(self, action: #selector(emailMeButtonAction), for: .touchUpInside)
    emailMeButton.frame = CGRect(x: 16, y: helpButton.frame.maxY + 32, width: kScreenWidth - 32, height: 22)
    view.addSubview(emailMeButton)
    
  }
  private var listModel:SymptomCheckReportModel!
  init(listModel:SymptomCheckReportModel) {
    super.init(nibName: nil, bundle: nil)
    self.listModel = listModel
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.bar.alpha = 0
    self.barAppearance(tintColor: .white,barBackgroundColor: .clear, image: R.image.return_left())
    self.view.backgroundColor = R.color.theamBlue()
    let deleteItem = UIBarButtonItem(image: R.image.symptom_check_nav_delete(), style: .plain, target: self, action: #selector(deleteItemAction))
    self.navigation.item.rightBarButtonItem = deleteItem
    self.configResult()
    self.refreshData()
  }
  
  func configResult() {
    let step1:[SymptomCheckStepModel] =  self.listModel.symptoms_qas?.map({ e -> SymptomCheckStepModel in
      let model = SymptomCheckStepModel()
      model.id = e.id
      model.title = e.title
      return model
    }) ?? []
    
    var step2:[SymptomCheckStepModel] = []
    let step2_0 = SymptomCheckStepModel()
    step2_0.id = self.listModel.best_describes_qa_id
    step2_0.title = self.listModel.best_describes_qa_title
    step2.append(step2_0)
    
    let step3:[SymptomCheckStepModel] =  self.listModel.pain_areas?.map({ e -> SymptomCheckStepModel in
      let model = SymptomCheckStepModel()
      model.id = e.id
      model.title = e.title
      return model
    }) ?? []
    
    self.result = [step1,step2,step3]
  }
  
  @objc func deleteItemAction() {
    AlertView.show(title: "Are you sure you want to delete this report", message: "You won’t be able to retrieve it", leftButtonTitle: "Cancel", rightButtonTitle: "Confirm", messageAlignment: .center, leftHandler: nil, dismissHandler:  {
      Toast.showLoading()
      let params = SOAPParams(action: .SymptomCheck, path: .deleteSymptomReportById)
      params.set(key: "id", value: self.listModel.id ?? "")
      NetworkManager().request(params: params) { data in
        Toast.dismiss()
        self.navigationController?.popViewController()
      } errorHandler: { e in
        Toast.dismiss()
      }
    })
  }
  
  override func refreshData() {
    
    when(fulfilled: getHeaderOverview(),getlist()).done { q2result,q23result in
      
      self.headerView.configData(q2result, self.result,self.listModel.fill_date)
      self.dataArray = q23result
      self.endRefresh()
      
    }.catch { e in
      Toast.showError(withStatus: e.asPKError.message)
    }
  }
  
  func getHeaderOverview() -> Promise<SymptomCheckQ1ResultModel>{
    return Promise.init { resolver in
      let params = SOAPParams(action: .SymptomCheck, path: .getQuestionDetails)
      let id = self.listModel.best_describes_qa_id ?? ""
      params.set(key: "id", value: id)
      NetworkManager().request(params: params) { data in
        guard let model = DecodeManager.decodeByCodable(SymptomCheckQ1ResultModel.self, from: data) else {
          resolver.reject(PKError.some( "Decode Failed"))
          return
        }
        resolver.fulfill(model)
      } errorHandler: { e in
        resolver.reject(PKError.some( e.asAPIError.errorInfo().message))
      }
    }
    
  }
  
  func getlist() -> Promise<[SymptomCheckQ23ResultModel]> {
    return Promise.init { resolver in
      let params = SOAPParams(action: .SymptomCheck, path: .getQuestionContentByQA23)
      
      let qaId2 = self.listModel.best_describes_qa_id ?? ""
      let qaIds3 = SOAPDictionary()
      let result3 = self.listModel.pain_areas?.map({ $0.id ?? "" }) ?? []
      for (i,e) in result3.enumerated() {
        qaIds3.set(key: i.string, value: e )
      }
      params.set(key: "qaId2", value: qaId2)
      params.set(key: "qaIds3", value: qaIds3.result, type: .map(1))
      
      NetworkManager().request(params: params) { data in
        guard let models = DecodeManager.decodeByCodable([SymptomCheckQ23ResultModel].self, from: data) else {
          resolver.reject(PKError.some( "Decode Failed"))
          return
        }
        resolver.fulfill(models)
      } errorHandler: { e in
        resolver.reject(PKError.some( e.asAPIError.errorInfo().message))
      }
      
    }
  }
  
  
  @objc func helpButtonAction() {
    let vc = SymptomCheckTreamentPlanWebController()
    self.navigationController?.pushViewController(vc)
  }
  
  @objc func emailMeButtonAction() {
    var resultDict:[Int:[SymptomCheckStepModel]] = [:]
    resultDict[1] = result[0]
    resultDict[2] = result[1]
    resultDict[3] = result[2]
    let vc = SymptomCheckEmailMeController(result: resultDict)
    self.navigationController?.pushViewController(vc)
  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: kScreenHeight)
    
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 300
    tableView?.register(nibWithCellClass: SymptomCheckDetailCell.self)
    tableView?.bounces = false
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 130 + kBottomsafeAreaMargin, right: 0)
    headerView.updateCompleteHandler = { [weak self] height in
      guard let `self` = self else { return }
      self.headerView.height = height
      self.tableView?.tableHeaderView = self.headerView
    }
    
    self.view.addSubview(footerView)
    footerView.frame = CGRect(x: 0, y: kScreenHeight - 130 - kBottomsafeAreaMargin, width: kScreenWidth, height: 130 + kBottomsafeAreaMargin)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: SymptomCheckDetailCell.self)
    if dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? SymptomCheckQ23ResultModel
    }
    return cell
  }
}
