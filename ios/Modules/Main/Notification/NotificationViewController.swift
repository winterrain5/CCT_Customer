//
//  NotificationViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/29.
//

import UIKit
import Haptica
import SideMenuSwift
import SwipeCellKit
class NotificationViewController: BaseTableController,UIGestureRecognizerDelegate {
  
  var filterIds:[String] = []
  var isAllowSelect = false
  var selectModels:[NotificationModel] = []
  var undoParams = SOAPDictionary()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(menuDidClick(_:)), name: .menuDidOpenVc, object: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigation.item.title = "Notification"
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: nil, backButtonTitle: nil)
    self.notAllSelectItemStyle()
    self.showSkeleton()
    self.refreshData()
    
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  func getClientCategory() {
    let params = SOAPParams(action: .Notifications, path: .getClientCategory)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")

    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(ClientCategoryModel.self, from: data) {
        if model.status == 0 {
          self.getAllCategories(0)
        }else {
          self.filterIds = model.models.map({ $0.category_id })
          self.getNotices()
        }
      }
    } errorHandler: { e in
      self.hideSkeleton()
    }

  }
  
  /// 获取所有分类
  /// - Parameter type: 0 赋值全部 1 弹窗
  func getAllCategories(_ type:Int) {
    let params = SOAPParams(action: .Notifications, path: .getAllCategories)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(NotificationCategoryModel.self, from: data) {
        if type == 0 {
          self.filterIds = models.map({ $0.id })
          self.saveClientCategories()
          self.getNotices()
        }else {
          let filterModels = models.map({ e -> SettingFilterModel in
            let m = SettingFilterModel()
            m.id = e.id
            m.key_word = e.category_name
            m.is_on = self.filterIds.contains(e.id)
            return m
          })
          SettingFilterSheetView.show(with: filterModels, title: "Filter InBox") { models in
            self.filterIds = models.filter({ $0.is_on }).map({ $0.id })
            self.saveClientCategories()
            self.loadNewData()
          }
        }
      }
    } errorHandler: { e in
      self.hideSkeleton()
    }

  }
  
  func saveClientCategories() {
    let params = SOAPParams(action: .Notifications, path: .saveClientCategories)
    
    let ids = SOAPDictionary()
    filterIds.enumerated().forEach { i,e in
      ids.set(key: i.string, value: e)
    }
    
    params.set(key: "cateIds", value: ids.result, type: .map(1))
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")

    NetworkManager().request(params: params) { data in
      
    } errorHandler: { e in
      
    }


  }
  
  func deleteNotification() {
    let params = SOAPParams(action: .Notifications, path: .deleteNotices)
    
    let ids = SOAPDictionary()
    selectModels.enumerated().forEach { i,e in
      ids.set(key: i.string, value: e.id)
    }
    undoParams = ids
    params.set(key: "ids", value: ids.result, type: .map(1))
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.showSuccess(withStatus: "Successfully deleted")
      NotificationUndoView.show(count: self.selectModels.count) { [weak self] in
        guard let `self` = self else { return }
        self.undoNotification()
      }
      self.notAllSelectItemStyle()
      self.dataArray.removeAll()
      self.getNotices()
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
  
  func undoNotification() {
    let params = SOAPParams(action: .Notifications, path: .unDoNotices)
    params.set(key: "ids", value: undoParams.result, type: .map(1))
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.showSuccess(withStatus: "Successfully Undo")
      self.dataArray.removeAll()
      self.getNotices()
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
  
  func getNotices() {
    let params = SOAPParams(action: .Notifications, path: .getNotices)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    let filters = SOAPDictionary()
    filterIds.enumerated().forEach { i,e in
      filters.set(key: i.string, value: e)
    }
    
    params.set(key: "filters", value: filters.result, type: .map(1))
    
    
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      if let models = DecodeManager.decodeArrayByHandJSON(NotificationModel.self, from: data) {
        let e1 = models.filter({ $0.isToDay })
        let e2 = models.filter({ !$0.isToDay })
        if e1.count > 0 {
          self.dataArray.append(e1)
        }
        
        if e2.count > 0 {
          self.dataArray.append(e2)
        }
       
        self.endRefresh(models.count,emptyString: "You have no notifications")
        self.hideSkeleton()
        return
      }
      self.endRefresh(.NoData, emptyString: "You have no notifications")
      self.hideSkeleton()
    } errorHandler: { e in
      self.endRefresh(e.asAPIError.emptyDatatype)
      self.hideSkeleton()
      Toast.dismiss()
    }

  }
  
  override func refreshData() {
    if filterIds.isEmpty {
      getClientCategory()
      return
    }
    getNotices()
  }
  
  override func listViewFrame() -> CGRect {
    CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kTabBarHeight)
  }
  
  override func createListView() {
    super.createListView()
    
    registRefreshHeader()
    self.view.isSkeletonable = true
    self.tableView?.isSkeletonable = true
    cellIdentifier = NotificationCell.className
    
    tableView?.register(nibWithCellClass: NotificationCell.self)
    tableView?.estimatedRowHeight = 120
    tableView?.rowHeight = UITableView.automaticDimension
    
    let longGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(_:)))
    longGes.delegate = self
    tableView?.addGestureRecognizer(longGes)
    
  }
  

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (self.dataArray[section] as? [NotificationModel])?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: NotificationCell.self)
    if self.dataArray.count > 0 {
      let sectionModel = self.dataArray[indexPath.section] as? [NotificationModel]
      if sectionModel?.count ?? 0 > 0 {
        cell.model = sectionModel?[indexPath.row]
      }
    }
    cell.delegate = self
    cell.selectionStyle = .none
    return cell
  }
  
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = NotificationSectionView()
    if self.dataArray.count > 0 {
      let sectionModel = self.dataArray[section] as! [NotificationModel]
      if sectionModel.count > 0 {
        if sectionModel.first?.isToDay ?? false {
          view.label.text = "Today"
        }else {
          view.label.text = "Earlier"
        }
        
      }
    }
    
    return view
    
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return self.dataArray.count == 0 ? 0 : 30
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    Haptic.impact(.light).generate()
    processDataArray(indexPath)
    
  }
  
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func processDataArray(_ indexPath:IndexPath) {
    if self.dataArray.count > 0 {
      let sectionModels = self.dataArray[indexPath.section] as! [NotificationModel]
      
      if sectionModels.count > 0 {
        let sectionModel = sectionModels[indexPath.row]
        if isAllowSelect {
          sectionModel.isSelected.toggle()
          if sectionModel.isSelected {
            selectModels.append(sectionModel)
          }else {
            selectModels.removeAll(sectionModel)
          }
          self.navigation.item.title = "\(selectModels.count) Selected"
          self.tableView?.reloadRows(at: [indexPath], with: .none)
        }
      }
    }
    
  }
  
  
  @objc func leftItemAction() {
    if isAllowSelect {
      notAllSelectItemStyle()
      tableView?.reloadData()
      return
    }
    sideMenuController?.revealMenu()
  }
  
  @objc func rightItemAction() {
    
    if isAllowSelect {
      deleteNotification()
      return
    }
    getAllCategories(1)
  }
  
  
  func allowSelectItemStyle() {
    self.navigation.item.leftBarButtonItem = UIBarButtonItem(image: R.image.return_left(), style: .plain, target: self, action: #selector(leftItemAction))
    self.navigation.item.rightBarButtonItem = UIBarButtonItem(image: R.image.notification_delete(), style: .plain, target: self, action: #selector(rightItemAction))
    self.navigation.item.title = "0 Selected"
    isAllowSelect = true
  }
  
  func notAllSelectItemStyle() {
    self.navigation.item.leftBarButtonItem = UIBarButtonItem(image: R.image.notification_menu(), style: .plain, target: self, action: #selector(leftItemAction))
    self.navigation.item.rightBarButtonItem = UIBarButtonItem(image: R.image.notification_filter(), style: .plain, target: self, action: #selector(rightItemAction))
    self.navigation.item.title = "Notification"
    
    (self.dataArray as! [[NotificationModel]]).forEach({
      $0.forEach({ $0.isSelected = false })
    })
    selectModels.removeAll()
    isAllowSelect = false
  }
  
  @objc func longPressGes(_ ges:UIGestureRecognizer) {
    Haptic.impact(.light).generate()
    if ges.state == .ended {
      let point = ges.location(in: self.tableView)
      let indexPath = self.tableView?.indexPathForRow(at: point)
      allowSelectItemStyle()
      if let i = indexPath {
        processDataArray(i)
      }
    }
  }
  
  @objc func menuDidClick(_ noti:Notification) {
    let selStr = noti.object as! String
    let sel = NSSelectorFromString(selStr)
    if self.responds(to: sel) {
      self.perform(sel)
    }
  }
}

extension NotificationViewController:SwipeTableViewCellDelegate {
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    if orientation == .right {
      let delete = SwipeAction(style: .destructive, title: nil) { a, i in
        Haptic.impact(.light).generate()
        self.selectModels = [(self.dataArray[indexPath.section] as! [NotificationModel])[indexPath.row]]
        self.deleteNotification()
      }
      delete.image = R.image.notification_swip_delete()
      delete.backgroundColor = .white
      
      return [delete]
    }
   return nil
  }
  
  func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeOptions()
    options.backgroundColor = .white
    
    return options
    
  }
}

class NotificationSectionView: UIView {
  var label = UILabel().then { label in
    label.textColor = .black
    label.font = UIFont(name:.AvenirNextRegular,size:12)
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(label)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview().offset(6)
    }
  }
}
