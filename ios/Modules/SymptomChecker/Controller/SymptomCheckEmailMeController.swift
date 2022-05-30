//
//  SymptomCheckEmailMeController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/14.
//

import UIKit
import PromiseKit
class SymptomCheckEmailMeController: BaseTableController {
  private var headerView = SymptomCheckDetailHeaderView.loadViewFromNib()
  private var result:[Int:[SymptomCheckStepModel]] = [:]
  private var userModel = UserModel()
  private var sendButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size:14)
    btn.titleForNormal = "Send"
  }
  init(result:[Int:[SymptomCheckStepModel]] = [:]) {
    super.init(nibName: nil, bundle: nil)
    self.result = result
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(sendButton)
    sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
    sendButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(32)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(40 + kBottomsafeAreaMargin)
    }
    refreshData()
    getUserInfo()
  }
  
  @objc func sendButtonAction() {
    Toast.showLoading()
    firstly {
      getBase64Image()
    }.then { base64 in
      self.getTSystemConfig(base64)
    }.then { base64,email in
      self.sendReportByEmail(base64, email: email)
    }.done {
      Toast.showSuccess(withStatus: "Your report is send!")
      self.navigationController?.pushViewController(SymptomCheckBeginController())
    }.catch { e in
      Toast.showError(withStatus: e.asAPIError.errorInfo().message)
    }
  }
  
  func getUserInfo() {
    let params = SOAPParams(action: .Client, path: .getTClientPartInfo)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(UserModel.self, from: data) {
        self.userModel = model
      }
    } errorHandler: { e in
      
    }
  }
  
  override func refreshData() {
    if result.isEmpty { return }
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
          resolver.reject(APIError.requestError(code: -1, message: "Decode Failed"))
          return
        }
        resolver.fulfill(model)
      } errorHandler: { e in
        resolver.reject(e)
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
          resolver.reject(APIError.requestError(code: -1, message: "Decode Failed"))
          return
        }
        resolver.fulfill(models)
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  func getBase64Image() -> Promise<String>{
    Promise.init { resolve in
      self.headerView.backgroundColor = .white
      self.tableView?.DDGContentScrollScreenShot({ image in
        self.headerView.backgroundColor = R.color.theamBlue()
        if let str = image?.jpegBase64String(compressionQuality: 0.2) {
          resolve.fulfill(str)
        }else {
          resolve.reject(APIError.requestError(code: -1, message: "getBase64ImageString failed"))
        }
      })
    }
  }
  
  func getTSystemConfig(_ base64Image:String) -> Promise<(String,String)>{
    Promise.init { resolver in
      let params = SOAPParams(action: .SystemConfig, path: .getTSystemConfig)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      params.set(key: "columns", value: "receive_specific_email")
      NetworkManager().request(params: params) { data in
        guard let model = DecodeManager.decodeByCodable(SystemConfigModel.self, from: data) else {
          resolver.reject(APIError.requestError(code: -1, message: "Decode SystemConfigModel failed"))
          return
        }
        resolver.fulfill((base64Image,model.receive_specific_email ?? ""))
      } errorHandler: { e in
        resolver.reject(e)
      }
    }

  }
  
  func sendReportByEmail(_ base64Image:String,email:String) -> Promise<Void>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Sms, path: .sendSmsForEmail)
      
      let content = SOAPDictionary()
      let name = (userModel.first_name) + (userModel.last_name )
      content.set(key: "title", value: "[Chien Chi Tow] " + name + " (\(userModel.mobile)) " + "Analysis Report")
      content.set(key: "email", value: userModel.email)
      let message = "<p><img src=\"data:image/png;base64," + base64Image + "\" style=\"max-width:100%;\"/><br/></p>";
      content.set(key: "message", value: message.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;"))
  
      content.set(key: "company_id", value: Defaults.shared.get(for: .companyId) ?? "97")
      content.set(key: "from_email", value: email)
      content.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
      
      params.set(key: "params", value: content.result, type: .map(1))
      
      NetworkManager().request(params: params) { data in
        resolver.fulfill_()
      } errorHandler: { e in
        resolver.reject(APIError.requestError(code: -1, message: "Send Email Failed"))
      }
    }
  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: kScreenHeight)
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 300
    tableView?.register(nibWithCellClass: SymptomCheckDetailCell.self)
    tableView?.bounces = false
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
