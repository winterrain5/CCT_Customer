//
//  TellUsCondiitonController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/5/31.
//

import UIKit

class TellUsCondiitonController: BaseTableController {
  var headLabel = UILabel().then { label in
    label.text = "Tell us about your condition"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size: 24)
  }
  var nextButton = UIButton().then { btn in
    btn.backgroundColor = R.color.grayE0()
    btn.cornerRadius = 22
    btn.titleForNormal = "Next"
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size: 14)
    btn.isEnabled = false
  }
  var headView = TellUsConditionHeadView()
  private var selectIndexPath:IndexPath?
  private var result:[Int:[SymptomCheckStepModel]] = [:]
  private var questions:[(title:String,content:String)] = [
    (title:"Question 01",content:"What symptoms are you experiencing?"),
    (title:"Question 02",content:"What best describes your last activity?"),
    (title:"Question 03",content:"Which area are you experiencing pain?")
  ]
  var category:Int = 1
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    
    self.view.addSubview(headLabel)
    headLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.top.equalToSuperview().offset(32 + kNavBarHeight)
      make.height.equalTo(36)
    }
    self.view.addSubview(nextButton)
    nextButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(kBottomsafeAreaMargin + 40)
      make.height.equalTo(44)
    }
    nextButton.addTarget(self, action: #selector(bottomAction), for: .touchUpInside)
    
    refreshData()
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .SymptomCheck, path: .getQuestions)
    params.set(key: "questionCategory", value: category)
    Toast.showLoading()
    self.view.isUserInteractionEnabled = false
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decodeByCodable([SymptomCheckStepModel].self, from: data) else {
        return
      }
      models.forEach({ $0.isSelected = false })
      self.headView.updateContent(content: self.questions[self.category - 1])
      self.nextButton.isEnabled = false
      self.view.isUserInteractionEnabled = true
      self.nextButton.backgroundColor = R.color.grayE0()
      self.dataArray = models
      self.endRefresh()
      Toast.dismiss()
    } errorHandler: { e in
      Toast.dismiss()
      self.view.isUserInteractionEnabled = true
      self.endRefresh(e.emptyDatatype)
    }

  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    view.corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
    tableView?.addLightShadow(by: 16)
  }
  
  override func createListView() {
    super.createListView()
    tableView?.register(cellWithClass: SymptomCheckStepCell.self)
    tableView?.tableHeaderView = headView
    headView.size = CGSize(width: kScreenWidth - 48, height: 80)
    tableView?.rowHeight = 56
  }
  
  override func listViewFrame() -> CGRect {
    return CGRect(x: 24, y: 100 + kNavBarHeight, width: kScreenWidth - 48, height: kScreenHeight - kBottomsafeAreaMargin - 40 - 44 - 52 - 100 - kNavBarHeight)
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
  
    if category == 3 {
      nextButton.titleForNormal = "Done"
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
  
  @objc func bottomAction() {
    if category == 3 {
      let vc = BookingAppointmentController(type: .Treatment, result: result)
      self.navigationController?.pushViewController(vc)
      return
    }
    category += 1
    loadNewData()
  }
  
}


class TellUsConditionHeadView:UIView {
  var titleLabel = UILabel().then { label in
    label.font = UIFont(name: .AvenirNextDemiBold, size: 13)
    label.textColor = R.color.black333()
  }
  var contentLabel = UILabel().then { label in
    label.font = UIFont(name: .AvenirNextRegular, size: 16)
    label.textColor = R.color.black333()
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)
    addSubview(contentLabel)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview().inset(16)
    }
    contentLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(16)
      make.top.equalTo(titleLabel.snp.bottom)
    }
  }
  
  func updateContent(content:(title:String,content:String)) {
    titleLabel.text = content.title
    contentLabel.text = content.content
  }
}
