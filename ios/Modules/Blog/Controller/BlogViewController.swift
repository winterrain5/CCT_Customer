//
//  BlogViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import UIKit
import PromiseKit
import DDGScreenShot

class BlogViewController: BaseTableController {
  private var headerView = BlogHeaderSearchView.loadViewFromNib()
  private var sectionView = BlogSegmentSectionView()
  lazy var createBoardView = BlogCreateBoardSheetView()
  private var categoryId:String = ""
  private var selectBlogId:String = ""
  private var searchKey:SOAPDictionary?
  private var filterKey:SOAPDictionary?
  
  var userFilter:[BlogFilterLabel] = []
  var allFilter:[BlogFilterLabel] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let filterKey = Defaults.shared.get(for: .blogFilterKey) {
      self.filterKey = SOAPDictionary()
      self.filterKey?.result = filterKey
    }
    
    createNavivationItem()
    refreshData()
    getCategories()
  }

  func createNavivationItem() {
    let bookMark = UIBarButtonItem(image:R.image.blog_nav_bookmark(), style: .plain, target: self, action: #selector(bookmarkItemAction))
    let filter = UIBarButtonItem(image:R.image.blog_nav_filter(), style: .plain, target: self, action: #selector(filterItemAction))
    self.navigation.item.rightBarButtonItems = [bookMark,filter]
  }
  
  @objc func bookmarkItemAction() {
    let vc = BlogBoardsController()
    self.navigationController?.pushViewController(vc)
  }
  
  @objc func filterItemAction() {
    BlogFilterView.show(with: userFilter, all: allFilter) { result in
      self.loadNewData()
    }
  }
  
  override func refreshData() {
    when(fulfilled: getUserBlogFilers(),getAllBlogFilters()).done { user,all in
      self.userFilter = user
      self.allFilter = all
      let params = SOAPParams(action: .Blog, path: API.getAllBlogs)
      params.set(key: "companyId", value: 97)
      if self.categoryId == "0" {
        params.set(key: "isFeatured", value: 1)
      }else {
        params.set(key: "isFeatured", value: 0)
      }
      if let searchkey = self.searchKey {
        params.set(key: "searchData", value: searchkey.result,type: .map(1))
      }
      
      if user.count == 0 {
        params.set(key: "filterKeys", value: "", type: .map(1))
      }else {
        if user.count == all.count {
          params.set(key: "filterKeys", value: "", type: .map(1))
        }else {
          self.filterKey = SOAPDictionary()
          user.enumerated().forEach { i,e in
            self.filterKey?.set(key: i.string, value: e.id ?? "")
          }
          params.set(key: "filterKeys", value: self.filterKey?.result ?? "", type: .map(1))
        }
      }
     
      
      params.set(key: "categoryId", value: self.categoryId)
      params.set(key: "limit", value: kPageSize)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      
      NetworkManager().request(params: params) { data in
        guard let models = DecodeManager.decodeByCodable([BlogModel].self, from: data) else {
          self.endRefresh(.DecodeError)
          return
        }
        self.dataArray.append(contentsOf: models)
        self.endRefresh(models.count)
        
      } errorHandler: { error in
        self.endRefresh(error.emptyDatatype)
      }
    }.catch { e in
      
    }
    

  }
  
  func getCategories() {
    let params = SOAPParams(action: .Blog, path: API.getBlogCategories)
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decodeByCodable([BlogCategoryModel].self, from: data) else {
        return
      }
      let featured = BlogCategoryModel()
      featured.id = "0"
      featured.key_word = "Featured"
      
      var temp:[BlogCategoryModel] = []
      temp.append(featured)
      temp.append(contentsOf: models)
      self.sectionView.tags = temp
      
    } errorHandler: { error in
      self.endRefresh(error.emptyDatatype)
    }
  }
  
  func getAllBlogFilters() -> Promise<[BlogFilterLabel]>{
    return Promise.init { resolver in
      let params = SOAPParams(action: .Blog, path: API.getFilters)
      NetworkManager().request(params: params) { data in
        guard let models = DecodeManager.decodeByCodable([BlogFilterLabel].self, from: data) else {
          resolver.fulfill([])
          return
        }
        resolver.fulfill(models)
      } errorHandler: { error in
        resolver.reject(PKError.some(message: error.localizedDescription))
      }
    }
    
  }
   
  func getUserBlogFilers() -> Promise<[BlogFilterLabel]> {
    return Promise.init { resolver in
      let params = SOAPParams(action: .Blog, path: API.getClientBlogFilters)
      params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
      NetworkManager().request(params: params) { data in
        let strArray = JSON.init(from: data)?.arrayValue
        if let models = strArray?.map({ e -> BlogFilterLabel in
          let model = BlogFilterLabel()
          model.id = e.rawString()
          return model
        }) {
          resolver.fulfill(models)
        }else {
          resolver.fulfill([])
        }
      } errorHandler: { e in
        resolver.reject(PKError.some(message: e.localizedDescription))
      }

    }
  }
  
  func checkHasDefaultBoards() {
    Toast.showLoading()
    let params = SOAPParams(action: .Blog, path: API.checkHasDefaultBoards)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      self.getBoardsForAddBlog()
    } errorHandler: { e in
      self.getBoardsForAddBlog()
    }

  }
  
  func getBoardsForAddBlog() {
    let params = SOAPParams(action: .Blog, path: API.getBoardsForAddBlog)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      guard let boards = DecodeManager.decodeByCodable([BlogBoardModel].self, from: data) else {
        return
      }
      let saveBoardView = BlogSaveToBoardSheetView.loadViewFromNib()
      saveBoardView.boards = boards
      let size = CGSize(width: kScreenWidth, height: saveBoardView.viewHeight)
      EntryKit.display(view: saveBoardView,
                       size: size,
                       style: .sheet,
                       backgroundColor: UIColor.black.withAlphaComponent(0.8),
                       touchDismiss: true)
      
      saveBoardView.createBoardHandler = {
        EntryKit.dismiss {
          self.createBoardView.showView(from: self.view)
          self.createBoardView.contentView.addBoardHandler = {  text in
            self.saveBoard(text)
          }
        }
      }
      
      saveBoardView.selectBoardHandler = { model in
        self.saveBlogToBoard(boardId: model.id!)
      }
      
    } errorHandler: { error in
      
    }

  }
  
  func saveBoard(_ name:String) {
    let params = SOAPParams(action: .Blog, path: API.saveBoard)
    let data = SOAPDictionary()
    data.set(key: "id", value: 0)
    data.set(key: "name", value: name)
    data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
      
      self.createBoardView.dismiss()
      self.getBoardsForAddBlog()
      
    } errorHandler: { error in
      
    }
  }
  
  func saveBlogToBoard(boardId:String) {
    let params = SOAPParams(action: .Blog, path: API.saveBlogIntoBoard)
    let data = SOAPDictionary()
    data.set(key: "blog_id", value: selectBlogId)
    data.set(key: "board_id", value: boardId)
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
      // 修改cell状态
      self.updateCellBookmarkStatus(true)
      EntryKit.dismiss {
        Toast.showSuccess(withStatus: "Add Successful")
      }
      
    } errorHandler: { error in
      
    }
  }
  
  func deleteBlogFromBoard() {
    BlogBookmarkRemoveSheetView.show {
      Toast.showLoading()
      let params = SOAPParams(action: .Blog, path: API.deleteBlogFromBoard)
      params.set(key: "blogId", value: self.selectBlogId)
      NetworkManager().request(params: params) { data in
        Toast.dismiss()
        self.updateCellBookmarkStatus(false)
      } errorHandler: { e in
        
      }
    }
  }
  
  func updateCellBookmarkStatus(_ hasBook:Bool) {
    guard let index = (self.dataArray as! [BlogModel]).firstIndex(where: { $0.id == self.selectBlogId }) else {
      return
    }
    (self.dataArray as! [BlogModel])[index].has_booked = hasBook
    let indexPath = IndexPath(row: index, section: 0)
    self.tableView?.reloadRows(at: [indexPath], with: .none)
  }
  override func createListView() {
    super.createListView()
    headerView.size = CGSize(width: kScreenWidth, height: 126)
    headerView.searchHandler = { [weak self] text in
      guard let `self` = self else { return }
      self.searchKey = SOAPDictionary()
      self.searchKey?.set(key: "key_word", value: text)
      
      self.loadNewData()
    }
    tableView?.tableHeaderView = headerView
    tableView?.register(nibWithCellClass: BlogItemVerticalLayoutCell.self)
    tableView?.register(nibWithCellClass: BolgItemHorizontalLayoutCell.self)
    registRefreshHeader()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 0 {
      if dataArray.count == 0 { return 0 }
      let firstModel = (dataArray as! [BlogModel]).first
      if let _ = firstModel?.filters {
        return (kScreenWidth - 32) * 3 / 4 + 141
      }else {
        return (kScreenWidth - 32) * 3 / 4 + 111
      }
    }
    return 136
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell:BlogItemCell!
    if indexPath.row == 0 {
      cell = tableView.dequeueReusableCell(withClass: BlogItemVerticalLayoutCell.self)
    }else {
      cell = tableView.dequeueReusableCell(withClass: BolgItemHorizontalLayoutCell.self)
    }
    
    cell.selectionStyle = .none
    if self.dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? BlogModel
    }
    cell.shareHandler = { model in
      guard let url = URL(string: "\(APIHost().URL_BLOG_SHARE)\(model.id ?? "")"),let title = model.title else {
        return
      }
      ShareTool.shareBlog(title, url.absoluteString)

    }
    cell.bookmarkHandler = { [weak self] model in
      self?.selectBlogId = model.id!
      if model.has_booked { // 取消
        self?.deleteBlogFromBoard()
      }else {
        self?.checkHasDefaultBoards()
      }

    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    sectionView.segmentDidClickHandler = { [weak self] model in
      guard let `self` = self else { return }
      self.categoryId = model.id ?? ""
      self.loadNewData()
    }
    return sectionView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 62
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row > self.dataArray.count - 1 {
       return
    }
    let model = self.dataArray[indexPath.row] as! BlogModel
    let vc = BlogDetailViewController(blogId: model.id ?? "", hasBook: model.has_booked)
    self.navigationController?.pushViewController(vc)
  }
}
