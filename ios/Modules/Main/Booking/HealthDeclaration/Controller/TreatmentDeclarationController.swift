//
//  TreatmentDeclarationController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/17.
//

import UIKit
import PromiseKit
class TreatmentDeclarationController: BaseTableController {

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
    
    footView.healthDeclarationType = 2
    footView.confirmHander = { [weak self] sender in
      self?.savePatientResults(sender)
    }
    
    refreshData()
  }
  
  override func refreshData() {

    if isFirstLoad { Toast.showLoading() }
    when(fulfilled: getPostPartumItems(), getTAllItemsForCategory3(), getTAllItemsForCategory2()).done { a1,a2,a3 in
      
      Toast.dismiss()
      
      var temp:[HealthDeclarationModel] = []
      
      temp.append(contentsOf: a3)
      temp.append(contentsOf: a2)
      
      temp.forEach { e1 in
        a1.forEach { e2 in
          if e1.id == e2.id { // 相等则移除e1 留下e2
            temp.removeAll(e1)
            temp.append(e2)
          }
        }
      }
      
      temp.removeFirst(where: { $0.description_en == "Are you pregnant?" })
      temp.removeFirst(where: { $0.description_en == "Do you have irregular periods?" })
      

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
      self.endRefresh()
      self.hideSkeleton()
      
    }.catch { e in
      Toast.dismiss()
      self.endRefresh(e.asAPIError.emptyDatatype)
      self.hideSkeleton()
    }

  }
  
  /// 用户已经填写的
  func getPostPartumItems() -> Promise<[HealthDeclarationModel]> {
    Promise.init { resolver in
      let params = SOAPParams(action: .questionnaireSurvey, path: .getTAllItems)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "category", value: 3)
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeArrayByHandJSON(HealthDeclarationModel.self, from: data) {
          resolver.fulfill(model)
          return
        }
        resolver.reject(APIError.requestError(code: -1, message: "Decode HealthDeclarationModel Failed"))
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  func getTAllItemsForCategory3() -> Promise<[HealthDeclarationModel]> {
    Promise.init { resolver in
      let params = SOAPParams(action: .questionnaireSurvey, path: .getTAllItems)
      params.set(key: "clientId", value: 0)
      params.set(key: "category", value: 3)
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
    tableView?.register(nibWithCellClass: DeclarationRemarkCell.self)
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
        if type == .Remark {
          let cell = tableView.dequeueReusableCell(withClass: DeclarationRemarkCell.self)
          cell.model = model
          cell.selectionStyle = .none
          cell.remarkDidChange = { [weak self] model in
            self?.tableView?.reloadRows(at: [IndexPath(row: model.index, section: 0)], with: .none)
          }
          return cell
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
    summary_data.set(key: "remarks", value: temp.filter({ $0.formType == .Remark }).first?.remark ?? "")
    summary_data.set(key: "category", value: 3)
    summary_data.set(key: "location_id", value: bookedService.location_id)
    
    data.set(key: "Summary_Data", value: summary_data.result, keyType: .string, valueType: .map(1))
    
    let lines_Data = SOAPDictionary()
    
    for (i,e) in temp.enumerated() {
      if e.type == "remark" {
        continue
      }
      let lines = SOAPDictionary()
      lines.set(key: "questionnaire_id", value: e.id)
      lines.set(key: "result", value: e.result)
      
      lines_Data.set(key: i.string, value: lines.result, keyType: .string, valueType: .map(1))
    }
   
    data.set(key: "tcm_lines_data", value: lines_Data.result,keyType: .string,valueType: .map(1))
    
    
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
    if bookedService.wellness_treatment_type == "2" && bookedService.wellness_or_treatment == "2" {
      data.set(key: "create_queue_no", value: 1)
    }
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