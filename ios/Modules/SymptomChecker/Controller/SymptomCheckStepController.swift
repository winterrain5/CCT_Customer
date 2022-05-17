//
//  SymptomCheckStepController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/12.
//

import UIKit

class SymptomCheckStepController: BaseTableController {
  private var headerView = SymptomCheckStepHeaderView().then { view in
    view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 200)
  }
  private var stepTitleView = SymptomCheckStepTitleView()
  private var selectIndexPath:IndexPath?
  private var category:Int = 1
  private var result:[Int:[SymptomCheckStepModel]] = [:]
  private var questions:[String] = [
    "What symptoms are you experiencing?",
    "What best describes your last activity?",
    "Which area are you experiencing pain?"
  ]
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
    btn.titleForNormal = "Next"
    btn.isEnabled = false
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    refreshData()
  }
  
  override func refreshData() {
    view.isUserInteractionEnabled = false
    nextButton.isEnabled = false
    nextButton.backgroundColor = UIColor(hexString: "dddddd")
    let params = SOAPParams(action: .SymptomCheck, path: .getQuestions)
    params.set(key: "questionCategory", value: category)
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decodeByCodable([SymptomCheckStepModel].self, from: data) else {
        return
      }
      models.forEach({ $0.isSelected = false })
      self.view.isUserInteractionEnabled = true
      self.dataArray = models
      self.endRefresh()
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
      self.view.isUserInteractionEnabled = true
      self.endRefresh(e.emptyDatatype)
    }

  }
  
  override func backAction() {
    AlertView.show(title: "Are you sure you want to Exit?", rightHandler:  {
      self.navigationController?.popToRootViewController(animated: true)
    })
  }
  
  @objc func backButtonAction() {
    result.removeValue(forKey: category)
    category -= 1
    if category == 0 {
      self.backAction()
      return
    }
    result.removeValue(forKey: category)
    headerView.title = questions[category - 1]
    stepTitleView.progress.previous()
    loadNewData()
  }
  
  @objc func nextButtonAction() {
    if category == 3 {
      let vc = SymptomCheckLetGoController(result: result)
      self.navigationController?.pushViewController(vc)
      return
    }
    headerView.title = questions[category - 1]
    stepTitleView.progress.next()
    category += 1
    loadNewData()
  }
  
  func setupViews() {
    self.interactivePopGestureRecognizerEnable = false
    self.updateStatusBarStyle(true)
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: "Exit")
    
    self.navigation.bar.alpha = 0
    
    self.navigation.item.titleView = stepTitleView
    stepTitleView.size =  CGSize(width: kScreenWidth - 180, height: 4)
    
    self.view.addSubview(headerView)
    headerView.title = questions[0]
    
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
  }
  
  override func createListView() {
    super.createListView()
    tableView?.register(cellWithClass: SymptomCheckStepCell.self)
    tableView?.contentInset = UIEdgeInsets(top: 28, left: 0, bottom: 104, right: 0)
    tableView?.rowHeight = 56
    tableView?.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  override func listViewFrame() -> CGRect {
    return CGRect(x: 0, y: headerView.frame.maxY - 16, width: kScreenWidth, height: kScreenHeight - headerView.frame.maxY + 16)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: SymptomCheckStepCell.self)
    if dataArray.count > 0 {
      cell.model = dataArray[indexPath.row] as? SymptomCheckStepModel
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if category == 2 {
      if let sel = selectIndexPath  {
        let model = (dataArray[sel.row] as! SymptomCheckStepModel)
        model.isSelected = false
      }
      let model = (dataArray[indexPath.row] as! SymptomCheckStepModel)
      model.isSelected = true
      updateResult(model)
      selectIndexPath = indexPath
    }else {
      let model = (dataArray[indexPath.row] as! SymptomCheckStepModel)
      model.isSelected?.toggle()
      updateResult(model)
    }
  
    nextButton.isEnabled = true
    nextButton.backgroundColor = R.color.theamRed()
    self.reloadData()
  }
  
  func updateResult(_ model:SymptomCheckStepModel) {
    if result[category] == nil {
      result[category] = [SymptomCheckStepModel]()
    }
    var value = result[category]
    if model.isSelected ?? false{
      value?.append(model)
    }else {
      value?.removeAll(where: { $0.id == model.id })
    }
    result[category] = value
  }
}
