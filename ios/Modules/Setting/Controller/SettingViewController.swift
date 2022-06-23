//
//  SettingViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/28.
//

import UIKit
import PromiseKit
class SettingViewController: BaseTableController {
  
  private var headerView = UIView().then { view in
    view.backgroundColor = .white
    
    let titleLabel = UILabel()
    titleLabel.text = "Settings"
    titleLabel.font = UIFont(name: .AvenirNextDemiBold, size:24)
    titleLabel.textColor = R.color.theamBlue()
    
    view.addSubview(titleLabel)
    titleLabel.frame.origin = CGPoint(x: 24, y: 32)
    titleLabel.sizeToFit()
    
    let layer = CALayer()
    layer.backgroundColor = R.color.line()?.cgColor
    layer.frame = CGRect(x: 0, y: 92, width: kScreenWidth, height: 1)
    view.layer.addSublayer(layer)
  }
  
  private var footerView = UIView().then { view in
    view.backgroundColor = .white
    
    let versionLabel = UILabel()
    let infoDictionary = Bundle.main.infoDictionary!
    let majorVersion = infoDictionary["CFBundleShortVersionString"] as? String ?? ""//主程序版本号
    
    versionLabel.text = "Version \(majorVersion)\nChien Chi Tow Healthcare Pte Ltd"
    versionLabel.font = UIFont(name:.AvenirNextRegular,size:14)
    versionLabel.textColor = UIColor(hexString: "828282")
    versionLabel.numberOfLines = 2
    versionLabel.textAlignment = .center
    view.addSubview(versionLabel)
    
    versionLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  var models:[SettingModel] = [
    SettingModel(title: "Language", descption: "English", isSwitch: false),
    SettingModel(title: "Notification", descption: "Notification alerts is turned on", isSwitch: true),
    SettingModel(title: "Sync Phone Calendar", descption: "App is currently in sync", isSwitch: true),
    SettingModel(title: "InBox Content", descption: "", isSwitch: false),
    SettingModel(title: "Blog Content", descption: "", isSwitch: false),
    SettingModel(title: "Privacy Policy", descption: "", isSwitch: false),
    SettingModel(title: "Terms and Conditions", descption: "", isSwitch: false),
  ]
  var inBoxMaps:[Int:String] = [1:"Articles",2:"News Events",3:"Promotions",4:"Madam Partum"]
  var blogCategories:[BlogCategoryModel] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    refreshData()
  }
  
  override func refreshData() {
    
    when(fulfilled: self.getSettings(),self.getCategories()).done { setting,blogCategories in
      if setting.send_notification_by_en == "1" {
        self.models[0].descption = "English"
      }else {
        self.models[0].descption = "Chinese"
      }
      
      if setting.send_notification_by == "2" {
        self.models[1].descption = "Notification alerts is turned on"
        self.models[1].isOn = true
      }else {
        self.models[1].descption = "Notification alerts is turned off"
        self.models[1].isOn = false
      }
      
      if setting.sync_phone_calendar == "1" {
        self.models[2].descption = "App is currently in sync"
        self.models[2].isOn = true
      }else {
        self.models[2].descption = "App is not currently in sync"
        self.models[2].isOn = false
      }
      
      let inBoxContents = JSON(parseJSON: setting.inbox_content ?? "").rawValue as? [Int]
      var inBoxString:[String] = []
      inBoxContents?.forEach({ key in
        if self.inBoxMaps.keys.contains(key) {
          inBoxString.append(self.inBoxMaps[key] ?? "")
        }
      })
      self.models[3].descption = inBoxString.joined(separator: ",")
      
      
      let blogContents = JSON(parseJSON: setting.blog_content ?? "").rawValue as? [Int]
      var blogString:[String] = []
      blogContents?.forEach({ key in
        if blogCategories.contains(where: { $0.id == key.string }) {
          blogString.append(blogCategories.filter({ $0.id == key.string }).first?.key_word ?? "")
        }
      })
      self.models[4].descption = blogString.joined(separator: ",")
      
      
      self.models[0].originValue = setting.send_notification_by_en ?? ""
      self.models[1].originValue = setting.send_notification_by ?? ""
      self.models[2].originValue = setting.sync_phone_calendar ?? ""
      self.models[3].originValue = setting.inbox_content ?? ""
      self.models[4].originValue = setting.blog_content ?? ""
      
      self.blogCategories = blogCategories
      self.tableView?.reloadData()
    }.catch { e in
      self.tableView?.reloadData()
    }
    
  }
  
  func getSettings() -> Promise<SettingContentModel>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Client, path: .getClientSettings)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      NetworkManager().request(params: params) { data in
        guard let model = DecodeManager.decodeByCodable(SettingContentModel.self, from: data) else {
          resolver.reject(APIError.requestError(code: -1, message: "decode SettingContentModel failed"))
          return
        }
        resolver.fulfill(model)
      } errorHandler: { e in
        resolver.reject(e)
      }
    }
  }
  
  func getCategories() -> Promise<[BlogCategoryModel]>{
    Promise.init { resolver in
      let params = SOAPParams(action: .Blog, path: API.getBlogCategories)
      NetworkManager().request(params: params) { data in
        guard let models = DecodeManager.decodeByCodable([BlogCategoryModel].self, from: data) else {
          resolver.reject(APIError.requestError(code: -1, message: "decode BlogCategoryModel failed"))
          return
        }
        resolver.fulfill(models)
      } errorHandler: { error in
        resolver.reject(error)
      }
    }
  }
  
  func save() {
    let params = SOAPParams(action: .Client, path: .changeClientPartInfo)
    
    let data = SOAPDictionary()
    data.set(key: "send_notification_by_en", value: self.models[0].originValue)
    data.set(key: "send_notification_by", value: self.models[1].originValue)
    data.set(key: "sync_phone_calendar", value: self.models[2].originValue)
    data.set(key: "inbox_content", value: self.models[3].originValue)
    data.set(key: "blog_content", value: self.models[4].originValue)
    params.set(key: "data", value: data.result,type: .map(1))
    
    let log = SOAPDictionary()
    log.set(key: "create_uid", value: Defaults.shared.get(for: .userId) ?? "")
    log.set(key: "ip", value: "")
    
    params.set(key: "logData", value: log.result,type: .map(2))
    
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    NetworkManager().request(params: params) { data in
      self.loadNewData()
    } errorHandler: { e in
      
    }
    
    
  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: 92)
    
    tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 120)
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorColor = R.color.line()
    tableView?.separatorInset = .zero
    
    tableView?.register(nibWithCellClass: SettingCell.self)
    tableView?.rowHeight = UITableView.automaticDimension
    tableView?.estimatedRowHeight = 44
    
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 0 { return 0 }
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return models.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: SettingCell.self)
    cell.model = models[indexPath.row]
    cell.switchHandler = {[weak self] model in
      guard let `self` = self else { return }
      if model.title == "Notification" {
        self.models[1].originValue = model.isOn ? "2" : "0"
        if model.isOn {
          MobPush.restart()
        }else {
          MobPush.stop()
        }
        
      }
      if model.title == "Sync Phone Calendar" {
        self.models[2].originValue = model.isOn ? "1" : "0"
      }
      self.save()
    }
    cell.selectionStyle = .none
    return cell
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model = self.models[indexPath.row]
    if model.title == "InBox Content" {
      let inBoxContents = JSON(parseJSON: self.models[3].originValue).rawValue as? [Int]
      var inBoxFilters:[SettingFilterModel] = []
      self.inBoxMaps.keys.forEach({ key in
        if inBoxContents?.contains(key) ?? false{
          let model = SettingFilterModel()
          model.id = key.string
          model.is_on = true
          model.key_word = self.inBoxMaps[key] ?? ""
          inBoxFilters.append(model)
        }else {
          let model = SettingFilterModel()
          model.id = key.string
          model.is_on = false
          model.key_word = self.inBoxMaps[key] ?? ""
          inBoxFilters.append(model)
        }
      })
      SettingFilterSheetView.show(with: inBoxFilters, title: "Filter InBox") { filters in
        
        let inBoxContent = JSON.init(filters.filter({ $0.is_on }).map({ $0.id.int })).rawString()?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\\\"", with: "") ?? ""
        self.models[3].originValue = inBoxContent
        
        self.save()
      }
    }
    
    if model.title == "Blog Content" {
      let blogContents = JSON(parseJSON: self.models[4].originValue).rawValue as? [Int]
      var blogFilters:[SettingFilterModel] = []
      if self.blogCategories.count == 0 { return }
      self.blogCategories.forEach({ category in
        if blogContents?.contains(category.id?.int ?? 0) ?? false {
          let model = SettingFilterModel()
          model.id = category.id ?? ""
          model.is_on = true
          model.key_word = category.key_word ?? ""
          blogFilters.append(model)
        }else {
          let model = SettingFilterModel()
          model.id = category.id ?? ""
          model.is_on = false
          model.key_word = category.key_word ?? ""
          blogFilters.append(model)
        }
      })
      SettingFilterSheetView.show(with: blogFilters, title: "Blog Content") { filters in
        
        let inBoxContent = JSON.init(filters.filter({ $0.is_on }).map({ $0.id.int })).rawString()?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\\\"", with: "") ?? ""
        self.models[4].originValue = inBoxContent
        
        self.save()
      }
    }
    
    if model.title == "Terms and Conditions" {
      TCApplyPrivilegesSheetView.show()
    }
    
    if model.title == "Privacy Policy" {
      DataProtectionSheetView.show()
    }
  }
}
