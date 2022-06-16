//
//  PostPartumDeclarationController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/15.
//

import UIKit
import PromiseKit
class PostPartumDeclarationController: BaseTableController {
  
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
    
    
    footView.confirmHander = { [weak self] sender in
      self?.savePatientResults(sender)
    }
    
    refreshData()
  }
  
  override func refreshData() {

    if isFirstLoad { showSkeleton() }
    when(fulfilled: getPostPartumItems(), getTAllItemsForCategory1(), getTAllItemsForCategory2()).done { a1,a2,a3 in
      
      var temp:[HealthDeclarationModel] = []
      
      temp.append(contentsOf: a3)
      temp.append(contentsOf: a2)
      
      temp.forEach { e1 in
        a1.xgQuestions.forEach { e2 in
          if e1.id == e2.id { // 相等则移除e1 留下e2
            temp.removeAll(e1)
            temp.append(e2)
          }
        }
      }
      
      temp.removeFirst(where: { $0.description_en == "Are you pregnant?" })
      temp.removeFirst(where: { $0.description_en == "Do you have irregular periods?" })
      
      let dateModel = HealthDeclarationModel()
      dateModel.type = "date"
      dateModel.date = a1.postPartumFields?.delivery_estimated_date ?? ""
      let methodModel = HealthDeclarationModel()
      methodModel.type = "method"
      methodModel.mehtod_of_delivery = a1.postPartumFields?.delivery_method.string ?? "2"
      let remarkModel = HealthDeclarationModel()
      remarkModel.type = "remark"
      
      temp.append(dateModel)
      temp.append(methodModel)
      temp.append(remarkModel)
      
      self.dataArray = temp
      
      if self.dataArray.count > 0 {
        
        self.tableView?.tableHeaderView = self.headView
        self.headView.size = CGSize(width: kScreenWidth, height: 184)
        
        self.tableView?.tableFooterView = self.footView
        self.footView.size = CGSize(width: kScreenWidth, height: 604)
        
      }
      self.endRefresh()
      self.hideSkeleton()
      
    }.catch { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
      self.hideSkeleton()
    }

  }
  
  /// 用户已经填写的
  func getPostPartumItems() -> Promise<PostPartumModel> {
    Promise.init { resolver in
      let params = SOAPParams(action: .questionnaireSurvey, path: .getPostPartumItems)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "category", value: 5)
      NetworkManager().request(params: params) { data in
        if let model = DecodeManager.decodeObjectByHandJSON(PostPartumModel.self, from: data) {
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
    tableView?.register(nibWithCellClass: DeclarationRemarkCell.self)
    tableView?.register(nibWithCellClass: DeclarationFormDateOfDeliverCell.self)
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
      
      if model?.type == "date" {
        let cell = tableView.dequeueReusableCell(withClass: DeclarationFormDateOfDeliverCell.self)
        cell.model = model
        cell.selectionStyle = .none
        return cell
      }
      
      if model?.type == "method" {
        let cell = tableView.dequeueReusableCell(withClass: DeclarationFormMethodOfDeiveryCell.self)
        cell.model = model
        cell.selectionStyle = .none
        return cell
      }
      
      if model?.type == "remark" {
        let cell = tableView.dequeueReusableCell(withClass: DeclarationRemarkCell.self)
        cell.model = model
        cell.selectionStyle = .none
        cell.remarkDidChange = { [weak self] model in
          self?.tableView?.reloadRows(at: [IndexPath(row: model.index, section: 0)], with: .none)
        }
        return cell
      }

      let cell = tableView.dequeueReusableCell(withClass: DeclarationFormCell.self)
      cell.model = model
      cell.updateOptionsHandler = { [weak self] model in
        self?.tableView?.reloadRows(at: [IndexPath(row: model.index, section: 0)], with: .none)
      }
      cell.selectionStyle = .none
      
      return cell
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
    summary_data.set(key: "remarks", value: temp.filter({ $0.type == "remark"}).first?.remark ?? "")
    summary_data.set(key: "category", value: 5)
    summary_data.set(key: "location_id", value: bookedService.location_id)
    
    data.set(key: "Summary_Data", value: summary_data.result, keyType: .string, valueType: .map(1))
    
    let post_massage_record = SOAPDictionary()
    let xg_qa_lines_data = SOAPDictionary()
    let base_info = SOAPDictionary()
    
    base_info.set(key: "address", value: "")
    base_info.set(key: "delivery_estimated_date", value: temp.filter({ $0.type == "date" }).first?.date ?? "")
    base_info.set(key: "is_need_corset", value: 0)
    base_info.set(key: "is_need_slimming_oil", value: 0)
    base_info.set(key: "delivery_method", value: temp.filter({ $0.type == "method" }).first?.mehtod_of_delivery ?? "")
    
    for (i,e) in temp.enumerated() {
      if e.type == "remark" || e.type == "date" || e.type == "method" {
        continue
      }
      let lines = SOAPDictionary()
      lines.set(key: "questionnaire_id", value: e.id)
      lines.set(key: "result", value: e.result)
      
      xg_qa_lines_data.set(key: i.string, value: lines.result, keyType: .string, valueType: .map(1))
    }
   
    post_massage_record.set(key: "xg_qa_lines_data", value: xg_qa_lines_data.result,keyType: .string,valueType: .map(1))
    post_massage_record.set(key: "base_info", value: base_info.result,keyType: .string,valueType: .map(1))
    
    data.set(key: "post_massage_record", value: post_massage_record.result, keyType: .string, valueType: .map(1))
    
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
