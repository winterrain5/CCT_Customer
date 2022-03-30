//
//  BlogBookmarksController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/7.
//

import UIKit

class BlogBookmarksController: BaseTableController {

  private var headerView = BlogHeaderSearchView.loadViewFromNib()
  private var boardModel:BlogBoardModel?
  private var selectBlogId:String = ""
  init(boardModel:BlogBoardModel) {
    super.init(nibName: nil, bundle: nil)
    self.boardModel = boardModel
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshData()
  }
  
 
  override func refreshData() {
    let params = SOAPParams(action: .Blog, path: API.getClientBoardBlogs)
    params.set(key: "boardId", value: boardModel?.id ?? "")
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decode([BlogBookmarkedModel].self, from: data) else {
        self.endRefresh(.DecodeError)
        return
      }
      models.forEach({ $0.has_booked = true })
      self.dataArray.append(contentsOf: models)
      self.endRefresh(models.count)
      
    } errorHandler: { error in
      self.endRefresh(error.emptyDatatype)
    }

  }
  
  override func createListView() {
    super.createListView()
    headerView.size = CGSize(width: kScreenWidth, height: 126)
    let boardName = boardModel?.name ?? ""
    headerView.title = boardName
    headerView.isEnableEdit = true
    headerView.editHandler = { [weak self] in
      BlogBoardEditSheetView.show(with: boardName, confirmHandler: { name in
        self?.save(name)
      }, deleteHandler: {
        self?.delete()
      })
    }
    headerView.searchHandler = { [weak self] name in
      self?.getSearchData(name)
    }
    tableView?.tableHeaderView = headerView
    tableView?.register(nibWithCellClass: BlogBookmarkedCell.self)
    registRefreshHeader()
  }
  
  func getSearchData(_ name:String) {
    let params = SOAPParams(action: .Blog, path: API.searchClientBoardBlogs)
    params.set(key: "boardId", value: boardModel?.id ?? "")
    params.set(key: "searchKey", value: name)
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decode([BlogBoardModel].self, from: data) else {
        return
      }
      self.dataArray = models
      self.endRefresh(models.count)
    } errorHandler: { error in
      self.endRefresh(error.emptyDatatype)
    }
  }
  
  
  func save(_ name:String) {
    let params = SOAPParams(action: .Blog, path: API.saveBoard)
    let data = SOAPDictionary()
    data.set(key: "id", value: boardModel?.id ?? "")
    data.set(key: "name", value: name)
    data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
      EntryKit.dismiss()
      self.navigation.item.title = name
      self.headerView.title = name
      Toast.showSuccess(withStatus: "Edit Successful")
    } errorHandler: { error in
      
    }
  }
  
  func delete() {
    BlogBoardDeleteConfirmSheetView.show {
      let params = SOAPParams(action: .Blog, path: API.deleteBoard)
      params.set(key: "id", value: self.boardModel?.id ?? "")
      NetworkManager().request(params: params) { data in
        Toast.showSuccess(withStatus: "Delete Successful")
        self.navigationController?.popViewController()
      } errorHandler: { e in
        EntryKit.dismiss()
        
      }
    }
  }

  func deleteBlogFromBoard() {
    BlogBookmarkRemoveSheetView.show {
      Toast.showLoading()
      let params = SOAPParams(action: .Blog, path: API.deleteBlogFromBoard)
      params.set(key: "blogId", value: self.selectBlogId)
      NetworkManager().request(params: params) { data in
        Toast.dismiss()
        self.loadNewData()
      } errorHandler: { e in
        
      }
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 136
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BlogBookmarkedCell.self)
    cell.selectionStyle = .none
    if self.dataArray.count > 0 {
      cell.bookmarkedModel = self.dataArray[indexPath.row] as? BlogBookmarkedModel
    }
    cell.shareHandler2 = { model in
      guard let url = URL(string: "\(APIHost().URL_BLOG_SHARE)\(model.id ?? "")"),let title = model.title else {
        return
      }
      
      ShareTool.shareBlog(title, url.absoluteString)
    }
    cell.bookmarkHandler2 = { [weak self] model in
      self?.selectBlogId = model.id!
      self?.deleteBlogFromBoard()
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model = self.dataArray[indexPath.row] as! BlogBookmarkedModel
    let vc = BlogDetailViewController(blogId: model.id ?? "", hasBook: model.has_booked ?? false)
    self.navigationController?.pushViewController(vc)
  }
}
