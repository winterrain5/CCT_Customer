//
//  BlogBookmarksController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/7.
//

import UIKit

class BlogBoardsController: BaseCollectionController,UICollectionViewDelegateFlowLayout {
  lazy var createBoardView = BlogCreateBoardSheetView()
  private var isSearch:Bool = false
  override func viewDidLoad() {
    super.viewDidLoad()
    createNavivationItem()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadNewData()
  }
  
  func createNavivationItem() {
    let add = UIBarButtonItem(image:R.image.blog_bookmarks_board_add(), style: .plain, target: self, action: #selector(addNewBoardItemAction))
    self.navigation.item.rightBarButtonItem = add
  }
  
  @objc func addNewBoardItemAction() {
    
    self.createBoardView.showView(from: self.view)
    createBoardView.contentView.addBoardHandler = {  text in
      self.saveBoard(text)
    }
  }
  
  override func refreshData() {
    let params = SOAPParams(action: .Blog, path: API.getClientBoards)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decodeByCodable([BlogBoardModel].self, from: data) else {
        return
      }
      self.dataArray.append(contentsOf: models)
      self.endRefresh(models.count)
    } errorHandler: { error in
      self.endRefresh(error.emptyDatatype)
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
      Toast.showSuccess(withStatus: "Create Success")
      self.loadNewData()
    } errorHandler: { error in
      
    }
  }
  
  override func createListView() {
    super.createListView()
    collectionView?.register(nibWithCellClass: BlogBoardListCell.self)
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
    let cell = collectionView.dequeueReusableCell(withClass: BlogBoardListCell.self, for: indexPath)
    if self.dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? BlogBoardModel
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 0 {
      let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: BlogHeaderSearchView.self, for: indexPath)
      view.title = "Bookmarks"
      view.searchHandler = { [weak self] text in
        let datas = self?.dataArray as! [BlogBoardModel]
        if datas.count == 0 { return }
        let result = datas.filter({ $0.name?.contains(text ) ?? false })
        self?.dataArray = result
        self?.endRefresh(result.count)
      }
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
