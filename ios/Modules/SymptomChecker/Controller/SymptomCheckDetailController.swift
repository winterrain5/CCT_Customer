//
//  SymptomCheckDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit
import PromiseKit
import SkeletonView
class SymptomCheckDetailController: BaseTableController {
  private var headerView = SymptomCheckDetailHeaderView.loadViewFromNib()
 
  private var backButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = UIColor(hexString: "e0e0e0")
    btn.titleColorForNormal = R.color.black333()
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.titleForNormal = "Back"
  }
  private var nextButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.titleForNormal = "What’s Next?"
  }
  private var result:[Int:[SymptomCheckStepModel]] = [:]
  init(result:[Int:[SymptomCheckStepModel]] = [:]) {
    super.init(nibName: nil, bundle: nil)
    self.result = result
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.bar.alpha = 0
    self.interactivePopGestureRecognizerEnable = false
    self.barAppearance(tintColor: .white,barBackgroundColor: .clear, image: R.image.return_left(),backButtonTitle: "Exit")
    self.view.backgroundColor = R.color.theamBlue()
    
    self.view.addSubview(backButton)
    self.view.addSubview(nextButton)
    let buttonW = (kScreenWidth - 64 - 18) * 0.5
    backButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(32)
      make.width.equalTo(buttonW)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(40 + kBottomsafeAreaMargin)
    }
    nextButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-32)
      make.width.equalTo(buttonW)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(40 + kBottomsafeAreaMargin)
    }
    backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
    nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
    
    refreshData()
  }
  
  @objc func backButtonAction() {
    self.backAction()
  }
  
  @objc func nextButtonAction() {
    let vc = SymptomCheckWhatNextController(result: self.result)
    self.navigationController?.pushViewController(vc)
  }
  
  override func refreshData() {
    
    when(fulfilled: getHeaderOverview(),getlist()).done { q2result,q23result in
      var result:[[SymptomCheckStepModel]] = []
      self.result.sorted(by: { $0.key < $01.key}).forEach { key,value in
        result.append(value)
      }
      self.headerView.configData(q2result, result)
      self.dataArray = q23result
      self.endRefresh()
      
    }.catch { e in
      Toast.showError(withStatus: e.localizedDescription)
    }
  }
  
  func getHeaderOverview() -> Promise<SymptomCheckQ1ResultModel>{
    return Promise.init { resolver in
      let params = SOAPParams(action: .SymptomCheck, path: .getQuestionDetails)
      let id = result.filter({ $0.key == 2 }).first?.value.first?.id ?? ""
      params.set(key: "id", value: id)
      NetworkManager().request(params: params) { data in
        guard let model = DecodeManager.decodeByCodable(SymptomCheckQ1ResultModel.self, from: data) else {
          resolver.reject(PKError.some( "Decode Failed"))
          return
        }
        resolver.fulfill(model)
      } errorHandler: { e in
        resolver.reject(PKError.some( e.localizedDescription))
      }
    }
    
  }
  
  func getlist() -> Promise<[SymptomCheckQ23ResultModel]> {
    return Promise.init { resolver in
      let params = SOAPParams(action: .SymptomCheck, path: .getQuestionContentByQA23)

      let qaId2 = result.filter({ $0.key == 2 }).first?.value.first?.id ?? ""
      let qaIds3 = SOAPDictionary()
      let result3 = result.filter({ $0.key == 3 }).first?.value ?? []
      for (i,e) in result3.enumerated() {
        qaIds3.set(key: i.string, value: e.id ?? "")
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
        resolver.reject(PKError.some( e.localizedDescription))
      }

    }
  }
  
  override func backAction() {
    AlertView.show(title: "Are you sure you want to Exit?", rightHandler:  {
      self.navigationController?.popToRootViewController(animated: true)
    })
  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: kScreenHeight)
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 300
    tableView?.register(nibWithCellClass: SymptomCheckDetailCell.self)
    tableView?.bounces = true
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84 + kBottomsafeAreaMargin, right: 0)
    headerView.updateCompleteHandler = { [weak self] height in
      guard let `self` = self else { return }
      self.headerView.height = height
      self.tableView?.tableHeaderView = self.headerView
    }
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
