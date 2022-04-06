//
//  MadamPartumController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit
import PromiseKit
class MadamPartumController: BaseTableController {
  var rowHeight:[CGFloat] = [554,288,296]
  var headerView = MadamPartumHeaderView.loadViewFromNib()
  var footerView = MadamPartumFooterView.loadViewFromNib()
  var blogs:[BlogModel] = []
  var products:[FeatureProductModel] = []
  var services:[OurServicesByCategoryModel] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamPink()!, image: R.image.return_left())
    self.navigation.item.title = "Madam Partum"
    refreshData()
    getAllMP()
  }
  
  override func refreshData() {
    
    when(fulfilled: getFeaturedAllBlogs(),getNewFeaturedProducts(),getOurServicesByCategory()).done { blogs,products,services in
      
      self.blogs = blogs
      self.products = products
      self.services = services
      self.headerView.datas = blogs
      self.endRefresh()
      
      
    }.catch { e in
      Toast.showError(withStatus: e.asAPIError.errorInfo().message)
    }
  }
  
  func getFeaturedAllBlogs() -> Promise<[BlogModel]> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Blog, path: API.getAllBlogs)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      params.set(key: "isFeatured", value: 1)
      params.set(key: "categoryId", value: 0)
      params.set(key: "limit", value: 4)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      NetworkManager().request(params: params) { data in
        guard let models = DecodeManager.decodeByCodable([BlogModel].self, from: data) else {
          resolver.reject(APIError.requestError(code: -1, message: "decode failed"))
          return
        }
        resolver.fulfill(models)
        
      } errorHandler: { error in
        resolver.reject(error)
      }
    }
  }
  
  func getNewFeaturedProducts() -> Promise<[FeatureProductModel]> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Product, path: API.getNewFeaturedProducts)
      params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      params.set(key: "isFeatured", value: 1)
      params.set(key: "limit", value: 4)
      params.set(key:"isNew",value:"0");
      params.set(key:"isCctMap",value:"2");
      params.set(key:"isOnline",value:"1");
              
      
      NetworkManager().request(params: params) { data in
        guard let models = DecodeManager.decodeByCodable([FeatureProductModel].self, from: data) else {
          resolver.reject(APIError.requestError(code: -1, message: "decode failed"))
          return
        }
        resolver.fulfill(models)
        
      } errorHandler: { error in
        resolver.reject(error)
      }
    }
  }
  
  func getOurServicesByCategory() -> Promise<[OurServicesByCategoryModel]> {
    Promise.init { resolver in
      let params = SOAPParams(action: .Service, path: API.getOurServicesByCategory)
      params.set(key: "wellnessTreatTypes", value: 3)
      params.set(key: "limit", value: 4)
      NetworkManager().request(params: params) { data in

        guard let models = DecodeManager.decodeByCodable([OurServicesByCategoryModel].self, from: data) else {
          print("解析失败")
          resolver.reject(APIError.requestError(code: -1, message: "decode failed"))
          return
        }
        resolver.fulfill(models)

      } errorHandler: { error in
        resolver.reject(error)
      }
    }
  }
  
  func getAllMP() {
    let params = SOAPParams(action: .Company, path: .getAllMp)
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeByCodable([MadamPartumLocationModel].self, from: data) {
        self.footerView.datas = models
      }
    } errorHandler: { e in
      
    }

  }
  
  override func createListView() {
    super.createListView()
    
    self.tableView?.register(cellWithClass: MadamPartumNewsCell.self)
    self.tableView?.register(cellWithClass: MadamPartumProductCell.self)
    self.tableView?.register(cellWithClass: MadamPartumServiceCell.self)
    
    self.tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: 350)
    
    self.tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 866)
    footerView.updateHandler = { [weak self] totalH in
      self?.footerView.height = totalH
      self?.tableView?.tableFooterView = self?.footerView
    }
    
    self.tableView?.contentInset = .zero
    self.registRefreshHeader()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return rowHeight[indexPath.row]
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell:MadamPartumCell!
    if indexPath.row == 0 {
      cell = tableView.dequeueReusableCell(withClass: MadamPartumServiceCell.self)
      (cell as! MadamPartumServiceCell).datas = self.services
    }
    if indexPath.row == 1 {
      cell = tableView.dequeueReusableCell(withClass: MadamPartumNewsCell.self)
      (cell as! MadamPartumNewsCell).datas = self.blogs
    }
    if indexPath.row == 2 {
      cell = tableView.dequeueReusableCell(withClass: MadamPartumProductCell.self)
      (cell as! MadamPartumProductCell).datas = self.products
    }
    
    return cell
  }
  
}
