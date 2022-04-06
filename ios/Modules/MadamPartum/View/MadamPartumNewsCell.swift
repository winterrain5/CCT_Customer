//
//  MadamPartumNewsCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit

class MadamPartumNewsCell: MadamPartumCell {
  var datas:[BlogModel] = [] {
    didSet {
      collectionView.reloadData()
      pageControl.numberOfPages = datas.count / 2
    }
  }
  private var selectBlogId:String = ""
  override func configSubViews() {
    self.clvH = 184
    self.layout.itemSize = CGSize(width: 160, height: self.clvH)
    self.layout.numberOfItemsPerPage = 2
    super.configSubViews()
    self.collectionView.register(nibWithCellClass: MadamPartumNewsItemCell.self)
    self.typeLabel.text = "News"
    self.viewButton.titleForNormal = "View Blog"
    self.viewButton.isHidden = false
  }
  
  override func viewButtonAction() {
    let vc = BlogViewController()
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datas.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: MadamPartumNewsItemCell.self, for: indexPath)
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
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
          let size = CGSize(width: kScreenWidth, height: 295 + kBottomsafeAreaMargin)
          let createBoardView = BlogCreateBoardSheetView()
          EntryKit.display(view: createBoardView,
                           size: size,
                           style: .sheet,
                           backgroundColor: UIColor.black.withAlphaComponent(0.8),
                           touchDismiss: true)
          createBoardView.contentView.addBoardHandler = {  text in
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
      EntryKit.dismiss {
        self.getBoardsForAddBlog()
      }
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
    guard let index = self.datas.firstIndex(where: { $0.id == self.selectBlogId }) else {
      return
    }
    self.datas[index].has_booked = hasBook
    let indexPath = IndexPath(item: index, section: 0)
    self.collectionView.reloadItems(at: [indexPath])
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = datas[indexPath.item]
    let vc = BlogDetailViewController(blogId: model.id ?? "", hasBook: model.has_booked)
    UIViewController.getTopVC()?.navigationController?.pushViewController(vc)
  }
  
}
