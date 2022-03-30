//
//  BlogBookmarksController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/7.
//

import UIKit

class BlogBookmarkBoardsController: BaseCollectionController,UICollectionViewDelegateFlowLayout {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createNavivationItem()
    refreshData()
  }
  
  func createNavivationItem() {
    let add = UIBarButtonItem(image:R.image.blog_bookmarks_board_add(), style: .plain, target: self, action: #selector(addNewBoardItemAction))
    self.navigation.item.rightBarButtonItem = add
  }
  
  @objc func addNewBoardItemAction() {
    let size = CGSize(width: kScreenWidth, height: 295 + kBottomsafeAreaMargin)
    let createBoardView = BlogCreateBoardSheetView.loadViewFromNib()
    EntryKit.display(view: createBoardView,
                     size: size,
                     style: .sheet,
                     backgroundColor: UIColor.black.withAlphaComponent(0.8),
                     touchDismiss: true)
    createBoardView.addBoardHandler = {  text in
      self.saveBoard(text)
    }
  }
  
  override func refreshData() {
    let params = SOAPParams(action: Action.blog, path: API.getClientBoards)
    params.setValue(key: "clientId", value: clientId)
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decode([BlogBoardModel].self, from: data) else {
        return
      }
      self.dataArray.append(contentsOf: models)
      self.endRefresh(models.count)
    } errorHandler: { error in
      self.endRefresh(error.emptyDatatype)
    }

  }
  
  func saveBoard(_ name:String) {
    let params = SOAPParams(action: Action.blog, path: API.saveBoard)
    var data:[String:Any] = [:]
    data["id"] = 0
    data["name"] = name
    data["client_id"] = clientId
    params.setValue(key: "data", value: data)
    NetworkManager().request(params: params) { data in
      
    } errorHandler: { error in
      
    }
  }
  
  override func createListView() {
    super.createListView()
    collectionView?.register(nibWithCellClass: BlogBookmarkCell.self)
    collectionView?.register(nib: UINib(nibName: BlogHeaderSearchView.className, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: BlogHeaderSearchView.self)
    registRefreshHeader(colorStyle: .gray)
  }
  
  override func listViewLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 24
    layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
    return layout
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return 0
    }
    return self.dataArray.count
  }
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: BlogBookmarkCell.self, for: indexPath)
    if self.dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? BlogBoardModel
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 0 {
      let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: BlogHeaderSearchView.self, for: indexPath)
      view.title = "Bookmarks"
      return view
      
    }
    return UICollectionReusableView()
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return section == 0 ? CGSize.init(width:kScreenWidth, height:126) : .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (kScreenWidth - 56) * 0.5
    let height = floor(width * 3 / 4 + 52)
    return CGSize(width: width, height: height)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = self.dataArray[indexPath.item] as! BlogBoardModel
    let vc = BlogBookmarksController(boardModel: model)
    self.navigationController?.pushViewController(vc)
  }
}
