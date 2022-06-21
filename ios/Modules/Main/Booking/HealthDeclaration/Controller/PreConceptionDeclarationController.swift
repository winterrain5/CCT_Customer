//
//  PreConceptionDeclarationController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/16.
//

import UIKit
import PromiseKit
class PreConceptionDeclarationController: BaseTableController {
  
  var headView = DeclarationFormHeadView.loadViewFromNib()
  var footView = DeclarationFormFootView.loadViewFromNib()
  var prePartumField:PrePartumFields?
  var bookedService:BookingTodayModel!
  convenience init(bookedService:BookingTodayModel) {
    self.init()
    self.bookedService = bookedService
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = R.color.theamBlue()
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    
    footView.healthDeclarationType = 3
    footView.confirmHander = { [weak self] sender in
      self?.savePatientResults(sender)
    }
    
    refreshData()
  }
  
  
  override func refreshData() {
    
    if isFirstLoad { Toast.showLoading() }
    when(fulfilled: getPrePartumItems(), getTAllItemsForCategory1(), getTAllItemsForCategory2()).done { a1,a2,a3 in
      
      Toast.dismiss()
      
      var temp:[HealthDeclarationModel] = []
      var commonElements:[HealthDeclarationModel] = []
      a3.forEach { e1 in
        a1.xgQuestions.forEach { e2 in
          if e1.id == e2.id { // 相等则移除e1 留下e2
            commonElements.append(e2)
          }
        }
      }
      temp.append(contentsOf: commonElements)
      temp.append(contentsOf: a2)
      temp.removeDuplicates(keyPath: \.id)
      
      temp.removeFirst(where: { $0.description_en == "Are you pregnant?" })
      temp.removeFirst(where: { $0.description_en == "Do you have irregular periods?" })
      
      let weekNo = HealthDeclarationModel()
      weekNo.description_en = "Number of weeks into pregnancy?"
      weekNo.placeholder = "Enter no. of weeks"
      weekNo.formType = .Input
      weekNo.inputType = .PregnancyWeeks
      weekNo.text = a1.prePartumFields?.pregnancy_weeks ?? ""
      temp.append(weekNo)
      
      let dateModel = HealthDeclarationModel()
      dateModel.formType = .Date
      dateModel.description_en = "Estimated Due Date (EDD)"
      dateModel.delivery_date = a1.prePartumFields?.delivery_estimated_date ?? ""
      temp.append(dateModel)
      
      let name = HealthDeclarationModel()
      name.description_en = "Name of Gynecologist"
      name.placeholder = "Enter name"
      name.text = String(a1.prePartumFields?.name_phone_gynecologist?.split(separator: "/").first ?? "")
      name.inputType = .GynecologistName
      name.formType = .Input
      temp.append(name)
      
      let contactNo = HealthDeclarationModel()
      contactNo.description_en = "Gynecologist Contact Number"
      contactNo.placeholder = "Enter Contact No."
      contactNo.text = String(a1.prePartumFields?.name_phone_gynecologist?.split(separator: "/").last ?? "")
      contactNo.inputType = .GynecologistPhone
      contactNo.formType = .Input
      temp.append(contactNo)
      
      let doctorNote = HealthDeclarationModel()
      doctorNote.description_en = "Is your primary care physician aware you are receiving a massage, or do you have a doctor’s note?"
      doctorNote.result = a1.prePartumFields?.physician_aware_you ?? "3"
      doctorNote.id = "-1"
      temp.append(doctorNote)
      
      let firstmassage = HealthDeclarationModel()
      firstmassage.description_en = "Is this your first prenatal massage?"
      firstmassage.result = a1.prePartumFields?.is_first_massage.string ?? "3"
      firstmassage.id = "-2"
      temp.append(firstmassage)
      
      let elaborate1 = HealthDeclarationModel()
      elaborate1.placeholder = "Please elaborate"
      elaborate1.description_en = "Is your preganancy considered to be high risk?"
      elaborate1.result = a1.prePartumFields?.has_high_risk.string ?? "3"
      elaborate1.text = a1.prePartumFields?.high_risk_reasons ?? ""
      elaborate1.inputType = .HighRiskReason
      elaborate1.formType = .InputWithOptions
      temp.append(elaborate1)
      
      
      let elaborate2 = HealthDeclarationModel()
      elaborate2.description_en = "Have you had any complications or problems in this pregnancy? "
      elaborate2.placeholder = "Please elaborate"
      elaborate2.result = a1.prePartumFields?.has_any_complications.string ?? "3"
      elaborate2.text = a1.prePartumFields?.complications_problems ?? ""
      elaborate2.inputType = .ComplicationsProblems
      elaborate2.formType = .InputWithOptions
      temp.append(elaborate2)
      
      
      let focusArea = HealthDeclarationModel()
      focusArea.description_en = "What areas of the body would you like the therapist to focus on?"
      focusArea.placeholder = "Please elaborate"
      focusArea.formType = .FocusArea
      focusArea.focus_on_head = a1.prePartumFields?.focus_on_head ?? 0
      focusArea.focus_on_neck = a1.prePartumFields?.focus_on_neck ?? 0
      focusArea.focus_on_arms = a1.prePartumFields?.focus_on_arms ?? 0
      focusArea.focus_on_shoulders = a1.prePartumFields?.focus_on_shoulders ?? 0
      focusArea.focus_on_legs = a1.prePartumFields?.focus_on_legs ?? 0
      focusArea.focus_on_back = a1.prePartumFields?.focus_on_back ?? 0
      
      temp.append(focusArea)
      
      let remarkModel = HealthDeclarationModel()
      remarkModel.formType = .Remark
      temp.append(remarkModel)
      
      self.dataArray = temp
  
      if self.dataArray.count > 0 {
        
        self.tableView?.tableHeaderView = self.headView
        self.headView.size = CGSize(width: kScreenWidth, height: 184)
        
        self.tableView?.tableFooterView = self.footView
        self.footView.size = CGSize(width: kScreenWidth, height: 680)
        
      }
      
      self.prePartumField = a1.prePartumFields
      self.endRefresh()
      self.hideSkeleton()
      
    }.catch { e in
      Toast.dismiss()
      self.endRefresh(e.asAPIError.emptyDatatype)
      self.hideSkeleton()
    }
    
  }
  
  /// 用户已经填写的
  func getPrePartumItems() -> Promise<PrePartumModel> {
    Promise.init { resolver in
      let params = SOAPParams(action: .questionnaireSurvey, path: .getPrePartumItems)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "category", value: 4)
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(PrePartumModel.self, from: data) {
          resolver.fulfill(model)
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "Decode PostPartumModel Failed"))
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  func getTAllItemsForCategory1() -> Promise<[HealthDeclarationModel]> {
    Promise.init { resolver in
      let params = SOAPParams(action: .questionnaireSurvey, path: .getTAllItems)
      params.set(key: "clientId", value: 0)
      params.set(key: "category", value: 1)
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
  
  func getTAllItemsForCategory2() -> Promise<[HealthDeclarationModel]> {
    Promise.init { resolver in
      let params = SOAPParams(action: .questionnaireSurvey, path: .getTAllItems)
      params.set(key: "clientId", value: 0)
      params.set(key: "category", value: 2)
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
    tableView?.register(nibWithCellClass: DeclarationFormFocusAreaCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormInputWithOptionsCell.self)
    tableView?.register(nibWithCellClass: DeclarationRemarkCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormDateOfDeliverCell.self)
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
        switch type {
          case .Date:
            let cell = tableView.dequeueReusableCell(withClass: DeclarationFormDateOfDeliverCell.self)
            cell.model = model
            cell.selectionStyle = .none
            return cell
          case .InputWithOptions:
            let cell = tableView.dequeueReusableCell(withClass: DeclarationFormInputWithOptionsCell.self)
            cell.model = model
            cell.selectionStyle = .none
            return cell
          case .FocusArea:
            let cell = tableView.dequeueReusableCell(withClass: DeclarationFormFocusAreaCell.self)
            cell.model = model
            cell.selectionStyle = .none
            return cell
          case .Input:
            let cell = tableView.dequeueReusableCell(withClass: DeclarationFormInputCell.self)
            cell.model = model
            cell.selectionStyle = .none
            return cell
          case .Remark:
            let cell = tableView.dequeueReusableCell(withClass: DeclarationRemarkCell.self)
            cell.model = model
            cell.selectionStyle = .none
            cell.remarkDidChange = { [weak self] model in
              self?.tableView?.reloadRows(at: [IndexPath(row: model.index, section: 0)], with: .none)
            }
            return cell
          default:
          return UITableViewCell()
        }
        
      }else {
        let cell = tableView.dequeueReusableCell(withClass: DeclarationFormCell.self)
        cell.model = model
        cell.updateOptionsHandler = { [weak self] model in
          self?.tableView?.reloadRows(at: [IndexPath(row: model.index, section: 0)], with: .none)
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
    let summary_data = SOAPDictionary()
    
    let temp = self.dataArray as! [HealthDeclarationModel]
    
    summary_data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "0")
    summary_data.set(key: "registration_id", value: 0)
    summary_data.set(key: "create_time", value: Date().string(withFormat: "yyyy-MM-dd HH:mm:ss"))
    summary_data.set(key: "create_uid", value: 1)
    summary_data.set(key: "location_id", value: bookedService.location_id)
    summary_data.set(key: "remarks", value: temp.filter({ $0.type == "remark"}).first?.remark ?? "")
    summary_data.set(key: "category", value: 4)
    
    data.set(key: "Summary_Data", value: summary_data.result, keyType: .string, valueType: .map(1))
    
    let pre_partum_record = SOAPDictionary()
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
    
    pre_partum_record.set(key: "xg_qa_lines_data", value: xg_qa_lines_data.result,keyType: .string,valueType: .map(1))
    
    
    let base_info = SOAPDictionary()
    
    base_info.set(key: "address", value: "")
    let gynecologist_name = temp.filter({ $0.inputType == .GynecologistName }).first?.text ?? ""
    let gynecologist_phone = temp.filter({ $0.inputType == .GynecologistPhone }).first?.text ?? ""
    base_info.set(key: "name_phone_gynecologist", value:  gynecologist_name + "/" + gynecologist_phone)
    base_info.set(key: "physician_aware_you", value: temp.filter({$0.id == "-1"}).first?.result ?? "3")
    base_info.set(key: "pregnancy_weeks", value: temp.filter({ $0.inputType == .PregnancyWeeks }).first?.text ?? "")
    base_info.set(key: "delivery_estimated_date", value: temp.filter({ $0.formType == .Date }).first?.delivery_date ?? "")
    base_info.set(key: "is_first_massage", value: temp.filter({ $0.id == "-2" }).first?.result ?? "3")
    base_info.set(key: "has_high_risk", value: temp.filter({ $0.inputType == .HighRiskReason}).first?.result ?? "3")
    base_info.set(key: "high_risk_reasons", value: temp.filter({ $0.inputType == .HighRiskReason}).first?.text ?? "")
    base_info.set(key: "has_any_complications", value: temp.filter({ $0.inputType == .ComplicationsProblems}).first?.result ?? "3")
    base_info.set(key: "complications_problems", value: temp.filter({ $0.inputType == .ComplicationsProblems}).first?.text ?? "3")
    base_info.set(key: "focus_on_neck", value: temp.filter({ $0.formType == .FocusArea}).first?.focus_on_neck ?? 0)
    base_info.set(key: "focus_on_arms", value: temp.filter({ $0.formType == .FocusArea}).first?.focus_on_arms ?? 0)
    base_info.set(key: "focus_on_shoulders", value: temp.filter({ $0.formType == .FocusArea}).first?.focus_on_shoulders ?? 0)
    base_info.set(key: "focus_on_legs", value: temp.filter({ $0.formType == .FocusArea}).first?.focus_on_legs ?? 0)
    base_info.set(key: "focus_on_head", value: temp.filter({ $0.formType == .FocusArea}).first?.focus_on_head ?? 0)
    base_info.set(key: "focus_on_back", value: temp.filter({ $0.formType == .FocusArea}).first?.focus_on_back ?? 0)
    pre_partum_record.set(key: "base_info", value: base_info.result,keyType: .string,valueType: .map(1))
    
    data.set(key: "pre_partum_record", value: pre_partum_record.result, keyType: .string, valueType: .map(1))
    
    mapParams.set(key: "data", value: data.result,type: .map(1))
    
    sender.startAnimation()
    NetworkManager().request(params: mapParams) { data in
      self.chanageTStatus(sender)
    } errorHandler: { e in
      sender.stopAnimation()
    }
    
  }
  
  func chanageTStatus(_ sender:LoadingButton) {
    let mapParams = SOAPParams(action: .BookingOrder, path: .changeTStatus)
    mapParams.set(key: "timeId", value: bookedService.id)
    let data = SOAPDictionary()
    data.set(key: "status", value: 4)
    mapParams.set(key: "data", value: data.result,type: .map(1))
    
    NetworkManager().request(params: mapParams) { data in
      sender.stopAnimation()
      self.navigationController?.popToRootViewController(animated: true)
    } errorHandler: { e in
      sender.stopAnimation()
    }
    
  }
  
}