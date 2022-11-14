
//
//  ChildDeclarationController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit
import PromiseKit
import RxSwift
class ChildDeclarationController: BaseTableController {
  
  var headView = DeclarationFormHeadView.loadViewFromNib()
  var footView = DeclarationFormFootView.loadViewFromNib()
  
  var bookedService:BookingTodayModel!
  convenience init(bookedService:BookingTodayModel) {
    self.init()
    self.bookedService = bookedService
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = R.color.theamBlue()
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    
    footView.healthDeclarationType = bookedService.health_declaration_form_type
    footView.confirmHander = { [weak self] sender in
      self?.savePatientResults(sender)
    }
    
    refreshData()
  }
  
  override func refreshData() {
    
    if isFirstLoad { Toast.showLoading() }
    when(fulfilled: getUserTAllItems(), getTAllItemsForCategory7()).done { childModel,allModel in
      
      var temp:[HealthDeclarationModel] = []
      allModel.forEach { e1 in
        childModel.kidsQuestions.forEach { e2 in
          if e1.id == e2.id { 
            e1.result = e2.result
          }
        }
      }
      temp.append(contentsOf: allModel)
      temp.removeDuplicates(keyPath: \.id)
      
      let name = HealthDeclarationModel()
      name.description_en = "Child's Full Name"
      name.placeholder = "Enter name"
      name.text = childModel.kidsMassageFields?.name ?? ""
      name.formType = .Input
      name.inputType = .ChildName
      temp.append(name)
      
      let gender = HealthDeclarationModel()
      gender.description_en = "Child's Gender"
      gender.result = childModel.kidsMassageFields?.gender.string ?? "1"
      gender.formType = .ChildGender
      temp.append(gender)
      
      let date = HealthDeclarationModel()
      date.description_en = "Child's Date of Birth"
      date.child_birth_date = String(childModel.kidsMassageFields?.birthday.split(separator: " ").first ?? "")
      date.formType = .ChildBirthDate
      temp.append(date)
      
      let age = HealthDeclarationModel()
      age.description_en = "Child's Age"
      age.placeholder = "Enter age"
      age.text = childModel.kidsMassageFields?.age.string ?? ""
      age.formType = .Input
      age.inputType = .ChildAge
      temp.append(age)
      
      let certNo = HealthDeclarationModel()
      certNo.description_en = "Child's Birth Certificate No"
      certNo.placeholder = "Enter Birth Certificate No"
      certNo.text = childModel.kidsMassageFields?.birth_no ?? ""
      certNo.formType = .Input
      certNo.inputType = .ChildCertNo
      temp.append(certNo)
      
      let weight = HealthDeclarationModel()
      weight.description_en = "Child's Weight Percentile(%)"
      weight.placeholder = "Enter Weight Percentile"
      weight.text = childModel.kidsMassageFields?.weight ?? ""
      weight.formType = .Input
      weight.inputType = .ChildWeight
      temp.append(weight)
      
      let race = HealthDeclarationModel()
      race.description_en = "Race"
      race.result = childModel.kidsMassageFields?.race.string ?? ""
      race.text = childModel.kidsMassageFields?.race_other ?? ""
      race.formType = .ChildRace
      temp.append(race)
      
      let purpose = HealthDeclarationModel()
      purpose.description_en = "Purpose of declaration"
      purpose.result = childModel.kidsMassageFields?.purpose.string ?? ""
      purpose.formType = .PurposeOfDeclaration
      temp.append(purpose)
      
      
      let remark = HealthDeclarationModel()
      remark.description_en = "If any of the answers above is yes,please specify:"
      remark.text = childModel.kidsMassageFields?.specify ?? ""
      remark.formType = .Input
      remark.inputType = .Specify
      temp.append(remark)
      
      self.dataArray = temp
      
      if self.dataArray.count > 0 {
        
        self.tableView?.tableHeaderView = self.headView
        self.headView.size = CGSize(width: kScreenWidth, height: 184)
        
        self.tableView?.tableFooterView = self.footView
        self.footView.size = CGSize(width: kScreenWidth, height: 500)
        
      }
      Toast.dismiss()
      self.endRefresh()
      self.hideSkeleton()
    }.catch { error in
      Toast.dismiss()
      self.endRefresh(error.asAPIError.emptyDatatype)
      self.hideSkeleton()
    }

  }
  
  func getUserTAllItems() -> Promise<ChildDeclarationModel> {
    Promise.init { resolver in
      let params = SOAPParams(action: .questionnaireSurvey, path: .getKidsMassageItems)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "category", value: "7")
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(ChildDeclarationModel.self, from: data) {
          resolver.fulfill(model)
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "Decode ChildDeclarationModel Failed"))
      } errorHandler: { error in
        resolver.reject(error)
      }

    }
  }

  
  func getTAllItemsForCategory7() -> Promise<[HealthDeclarationModel]> {
    Promise.init { resolver in
      let params = SOAPParams(action: .questionnaireSurvey, path: .getTAllItems)
      params.set(key: "clientId", value: 0)
      params.set(key: "category", value: 7)
      params.set(key: "gender", value: Defaults.shared.get(for: .userModel)?.gender ?? "")
      NetworkManager().request(params: params) { data in
        if let models = DecodeManager.decodeArrayByHandJSON(HealthDeclarationModel.self, from: data) {
          resolver.fulfill(models)
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "Decode HealthDeclarationModel Failed"))
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  


  override func createListView() {
    super.createListView()
    
    
    tableView?.register(nibWithCellClass: DeclarationFormCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormInputCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormGenderCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormRaceCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormPurposeCell.self)
    tableView?.register(nibWithCellClass: DeclarationRemarkCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormDateCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormMethodOfDeiveryCell.self)
    tableView?.estimatedRowHeight = 100
    tableView?.rowHeight = UITableView.automaticDimension
    
    tableView?.bounces = false
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if self.dataArray.count > 0 {
      let model = self.dataArray[indexPath.row] as? HealthDeclarationModel
      model?.index = indexPath.row + 1
      
      if let type = model?.formType {
        if type == .DeliveryDate || type == .ChildBirthDate {
          let cell = tableView.dequeueReusableCell(withClass: DeclarationFormDateCell.self)
          cell.model = model
          cell.selectionStyle = .none
          return cell
        }
        
        if type == .DeliveryMethod {
          let cell = tableView.dequeueReusableCell(withClass: DeclarationFormMethodOfDeiveryCell.self)
          cell.model = model
          cell.selectionStyle = .none
          return cell
        }
        
        if type == .Remark {
          let cell = tableView.dequeueReusableCell(withClass: DeclarationRemarkCell.self)
          cell.model = model
          cell.selectionStyle = .none
          cell.remarkDidChange = { [weak self] model in
            self?.tableView?.reloadRows(at: [IndexPath(row: model.index - 2, section: 0)], with: .none)
          }
          return cell
        }
        
        if type == .Input {
          let cell = tableView.dequeueReusableCell(withClass: DeclarationFormInputCell.self)
          cell.model = model
          cell.selectionStyle = .none
          return cell
        }
        
        
        if type == .ChildGender {
          let cell = tableView.dequeueReusableCell(withClass: DeclarationFormGenderCell.self)
          cell.model = model
          cell.selectionStyle = .none
          return cell
        }
        
        if type == .ChildRace {
          let cell = tableView.dequeueReusableCell(withClass: DeclarationFormRaceCell.self)
          cell.model = model
          cell.selectionStyle = .none
          return cell
        }
        
        if type == .PurposeOfDeclaration {
          let cell = tableView.dequeueReusableCell(withClass: DeclarationFormPurposeCell.self)
          cell.model = model
          cell.selectionStyle = .none
          return cell
        }
        
      }else {
        let cell = tableView.dequeueReusableCell(withClass: DeclarationFormCell.self)
        cell.model = model
        cell.updateOptionsHandler = { [weak self] model in
          self?.tableView?.reloadRows(at: [IndexPath(row: model.index - 1, section: 0)], with: .none)
        }
        cell.selectionStyle = .none
        
        return cell
      }
     
    }
    return UITableViewCell()
  }
  
  func savePatientResults(_ sender:LoadingButton) {
    let mapParams = SOAPParams(action: .questionnaireSurvey, path: .savePatientResults)
    
    let data = SOAPDictionary()
    
    let temp = self.dataArray as! [HealthDeclarationModel]
    
    let summary_data = SOAPDictionary()
    summary_data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "0")
    summary_data.set(key: "registration_id", value: 0)
    summary_data.set(key: "create_time", value: Date().string(withFormat: "yyyy-MM-dd HH:mm:ss"))
    summary_data.set(key: "create_uid", value: 1)
    summary_data.set(key: "remarks", value: "")
    summary_data.set(key: "category", value: 7)
    summary_data.set(key: "location_id", value: bookedService.location_id)
    data.set(key: "Summary_Data", value: summary_data.result, keyType: .string, valueType: .map(1))
    
    let xg_qa_lines_data = SOAPDictionary()
    for (i,e) in temp.enumerated() {
      if e.type == "remark" || e.type == "date" || e.type == "method" {
        continue
      }
      let lines = SOAPDictionary()
      lines.set(key: "questionnaire_id", value: e.id)
      lines.set(key: "result", value: e.result)
      
      xg_qa_lines_data.set(key: i.string, value: lines.result, keyType: .string, valueType: .map(1))
    }
    data.set(key: "health_lines_data", value: xg_qa_lines_data.result,keyType: .string,valueType: .map(1))
    
    
    let paediatric_massage_record = SOAPDictionary()
    let base_info = SOAPDictionary()
    base_info.set(key: "name", value: temp.filter({ $0.inputType == .ChildName}).first?.text ?? "")
    base_info.set(key: "age", value: temp.filter({ $0.inputType == .ChildAge}).first?.text ?? "")
    base_info.set(key: "weight", value: temp.filter({ $0.inputType == .ChildWeight}).first?.text ?? "")
    base_info.set(key: "birthday", value: temp.filter({ $0.formType == .ChildBirthDate}).first?.child_birth_date ?? "")
    base_info.set(key: "birth_no", value: temp.filter({ $0.inputType == .ChildCertNo}).first?.text ?? "")
    base_info.set(key: "race", value: temp.filter({ $0.formType == .ChildRace}).first?.result ?? "")
    base_info.set(key: "race_other", value: temp.filter({ $0.formType == .ChildRace}).first?.text ?? "")
    base_info.set(key: "purpose", value: temp.filter({ $0.formType == .PurposeOfDeclaration}).first?.result ?? "")
    base_info.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "0")
    paediatric_massage_record.set(key: "base_info", value: base_info.result, keyType: .string, valueType: .map(1))
    
    data.set(key: "paediatric_massage_record", value: paediatric_massage_record.result, keyType: .string, valueType: .map(1))
    
    mapParams.set(key: "data", value: data.result,type: .map(1))
    
    sender.startAnimation()
    NetworkManager().request(params: mapParams) { data in
      self.chanageTStatus(sender)
    } errorHandler: { e in
      sender.stopAnimation()
    }

  }
  
  func saveQuestionStatus(_ sender: LoadingButton) {
    let params = SOAPParams(action: .BookingOrder, path: .saveQuestionStatus)
    params.set(key: "bookingId", value: bookedService.booking_order_time_id)
    params.set(key: "status", value: 2)
    NetworkManager().request(params: params) { data in
      if let result = JSON.init(from: data)?.stringValue, result == "1" {
        self.setRootViewController()
      }else{
        AlertView.show(message: "Save Question Status Failed")
        sender.stopAnimation()
      }
    } errorHandler: { e in
      sender.stopAnimation()
    }
  }
  
  
  func chanageTStatus(_ sender:LoadingButton) {
    let mapParams = SOAPParams(action: .BookingOrder, path: .changeTStatus)
    let timeID = bookedService.booking_order_time_id.isEmpty ? bookedService.id : bookedService.booking_order_time_id
    mapParams.set(key: "timeId", value: timeID)
    let data = SOAPDictionary()
    data.set(key: "status", value: 4)
    mapParams.set(key: "data", value: data.result,type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      sender.stopAnimation()
      
      if self.bookedService.booking_order_time_id.isEmpty {
        self.setRootViewController()
      } else {
        self.saveQuestionStatus(sender)
      }
      
     
    } errorHandler: { e in
      sender.stopAnimation()
    }

  }
  func setRootViewController() {
    if Defaults.shared.get(for: .isLoginByScanQRCode) == true {
      ApplicationUtil.setRootViewController()
    }else {
      NotificationCenter.default.post(name: NSNotification.Name.bookingDataChanged, object: nil)
      self.navigationController?.popToRootViewController(animated: true)
    }
  }
  
}
