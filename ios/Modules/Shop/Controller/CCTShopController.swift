//
//  CCTShopController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/12.
//

import UIKit

class CCTShopController: BaseCollectionController,UICollectionViewDelegateFlowLayout {
  private let headerHeight:CGFloat = 341
  private let footerHeight:CGFloat = 132
  private var bannerDatas:[ShopProductModel] = []
  private var requestModel = CCTShopFilterRequestModel()
  private var isCCT = false
  private var isCctMap:String = ""
  private var searchValue = ""
  private var isFilter = true
  convenience init(isCCT:Bool) {
    self.init()
    self.isCCT = isCCT
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if isCCT {
      isCctMap = "1"
      self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left())
    }else {
      isCctMap = "2"
      self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamPink()!, image: R.image.return_left())
    }
    let heartItem = UIBarButtonItem(image: R.image.shop_nav_heart()!, style: .plain, target: self, action: #selector(shopHertBarItemAction))
    let basketItem = UIBarButtonItem(image: R.image.shop_nav_basket()!, style: .plain, target: self, action: #selector(shopBasketBarItemAction))
    self.navigation.item.rightBarButtonItems = [basketItem,heartItem]
    self.navigation.item.title = "shop"
    
    
    refreshData()
    getBannerData()
  }
  
  override func refreshData() {
    if isFilter {
      getProductByFilters()
    }else {
      searchSourceByPage()
    }
    
  }
  
  func getProductByFilters() {
    let params = SOAPParams(action: .Product, path: .getProductsByFilters)
    
    let data = SOAPDictionary()
    data.set(key: "isCctMap", value: isCctMap)
    let categoryId = requestModel.category.map({ $0.id })
    data.set(key: "categoryId", value: categoryId.joined(separator: ","))
    data.set(key: "price_low", value: requestModel.price_low)
    data.set(key: "price_high", value: requestModel.price_high)
    data.set(key: "orderBy", value: requestModel.orderBy)
    
    params.set(key: "data", value: data.result, type: .map(1))
    
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "start", value: page)
    params.set(key: "length", value: kPageSize)
    params.set(key: "isOnline", value: 1)
    params.set(key: "searchValue", value: searchValue)
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
        self.dataArray.append(contentsOf: models)
        self.endRefresh(models.count, emptyString: "No Products Found")
      }else {
        self.endRefresh(.NoData, emptyString: "No Products Found")
      }
      
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
    }
    
  }
  
  func searchSourceByPage() {
    let params = SOAPParams(action: .Product, path: .searchSourcesByPages)
    

    params.set(key: "isCctMap", value: isCctMap)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "start", value: page)
    params.set(key: "length", value: kPageSize)
    params.set(key: "isOnline", value: 1)
    params.set(key: "searchValue", value: searchValue)
    params.set(key: "isCctMap", value: isCCT.int)
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
        self.dataArray.append(contentsOf: models)
        self.endRefresh(models.count, emptyString: "No Products Found")
      }else {
        self.endRefresh(.NoData, emptyString: "No Products Found")
      }
      
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
    }
  }
  
  func getBannerData() {
    let params = SOAPParams(action: .Product, path: .getNewFeaturedProducts)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "isFeatured", value: 1)
    params.set(key: "isNew", value: "false")
    params.set(key: "isOnline", value: 1)
    params.set(key: "isCctMap", value: isCctMap)
    params.set(key: "limit", value: 4)
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ShopProductModel.self, from: data) {
        self.bannerDatas = models
        self.reloadData()
      }
      
    } errorHandler: { e in
      
    }
  }
  
  @objc func shopHertBarItemAction() {
    let vc = ShopLikeProductController()
    self.navigationController?.pushViewController(vc)
  }
  
  @objc func shopBasketBarItemAction() {
    let vc = ShopCartController()
    self.navigationController?.pushViewController(vc)
  }
  
  override func createListView() {
    super.createListView()
    
    collectionView?.register(nibWithCellClass: ShopProductItemCell.self)
    
    collectionView?.register(UINib(nibName: "CCTShopHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:CCTShopHeaderView.className)
    
    collectionView?.register(UINib(nibName: "CCTShopFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier:CCTShopFooterView.className)
    
    collectionView?.register(CCTShopNoneView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CCTShopNoneView.className)
   
    collectionView?.register(CCTShopNoneView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CCTShopNoneView.className)
    registRefreshHeader()
    registRefreshFooter()
  }
  
  override func listViewLayout() -> UICollectionViewLayout {
    let layout = HoverViewFlowLayout(navHeight: 0)
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    layout.itemSize = CGSize(width: (kScreenWidth - 48 - 8) * 0.5, height: 200)
    layout.scrollDirection = .vertical
    return layout
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 { return 0 }
    return self.dataArray.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: ShopProductItemCell.self, for: indexPath)
    if self.dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.item] as? ShopProductModel
      cell.likeHandler = { [weak self] model in
        self?.updateCellIsLikeStatus(model)
      }
    }
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = dataArray[indexPath.item] as! ShopProductModel
    let vc = ShopDetailController(productId: model.id)
    self.navigationController?.pushViewController(vc)
  }
  
  func updateCellIsLikeStatus(_ model:ShopProductModel) {
    guard let index = (self.dataArray as! [ShopProductModel]).firstIndex(where: { $0.id == model.id }) else {
      return
    }
    let indexPath = IndexPath(item: index, section: 1)
    self.collectionView?.reloadItems(at: [indexPath])
  }
  
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 0 {
      if kind == UICollectionView.elementKindSectionHeader {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CCTShopHeaderView.className, for: indexPath)
        (view as! CCTShopHeaderView).isCCT = isCCT
        (view as! CCTShopHeaderView).datas = self.bannerDatas
        return view
      }
      if kind == UICollectionView.elementKindSectionFooter {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CCTShopFooterView.className, for: indexPath)
        let footerView = (view as! CCTShopFooterView)
        footerView.filterHandler = { [weak self] in
          guard let `self` = self else { return }
          
          ShopFilterView.show(lastSelect:self.requestModel) { [weak self] result in
            guard let `self` = self else { return }
            self.isFilter = true
            self.requestModel = result
            footerView.result = result
            self.loadNewData()
          }
          
        }
        footerView.updateFilterHandler = { [weak self] result in
          guard let `self` = self else { return }
          self.isFilter = true
          self.requestModel = result
          self.loadNewData()
        }
        footerView.searchView.searchDidEndHandler = {
          [weak self] text in
          self?.isFilter = false
          self?.searchValue = text
          self?.loadNewData()
        }
        return view
      }
    }
    return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: CCTShopNoneView.self, for: indexPath)
    
   
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return section == 0 ? CGSize.init(width:kScreenWidth, height:headerHeight) : .zero
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return section == 0 ? CGSize.init(width:kScreenWidth, height:footerHeight) : .zero
  }
  
  func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
    return -(footerHeight + headerHeight) * 0.5
  }
}

class CCTShopNoneView: UICollectionReusableView {
  
}

@objcMembers class CCTShopFilterRequestModel:BaseModel {
  var price_high = ""
  var price_low = ""
  var category:[ProductCategoryModel] = []
  var orderBy = ""
  var range:String = ""
}
