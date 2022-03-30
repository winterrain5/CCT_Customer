//
//  MadamPartumDetailController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/21.
//

import UIKit

class MadamPartumStoryController: BaseTableController {
  private var headerView = MadamPartumDetailHeaderView.loadViewFromNib()
  private var footerView = MadamPartumDetailFooterView.loadViewFromNib()
  override func viewDidLoad() {
    super.viewDidLoad()
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamPink()!, image: R.image.return_left())
    self.navigation.item.title = "Madam Partum"
    refreshData()
    
  }
  
  override func refreshData() {
    getAwards()
    getLatesReviews()
  }
  
  func getAwards() {
    let params = SOAPParams(action: .Company, path: .getAwards)
    params.set(key: "cctMP", value: 2)
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decode([AwardsModel].self, from: data) else {
        self.endRefresh(.NoData)
        return
      }
      self.dataArray = models
      self.endRefresh()
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }

  }
  
  func getLatesReviews() {
    let params = SOAPParams(action: .Sale, path: .getLastClientReviews)
    params.set(key: "limit", value: 3)
    NetworkManager().request(params: params) { data in
      guard let models = DecodeManager.decode([ClientReviewModel].self, from: data) else {
        return
      }
      self.footerView.models = models
      
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }
  }
  
  override func createListView() {
    super.createListView()
    
    self.tableView?.register(nibWithCellClass: MadamPartumAwardsCell.self)
    
    self.tableView?.tableHeaderView = headerView
    if iPhoneX() {
      headerView.size = CGSize(width: kScreenWidth, height: 2792)
    }else {
      headerView.size = CGSize(width: kScreenWidth, height: 2830)
    }
    
    
    self.tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 442)
    
    self.tableView?.backgroundColor = R.color.theamYellow()
    self.tableView?.rowHeight = UITableView.automaticDimension
    self.tableView?.estimatedRowHeight = 80
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: MadamPartumAwardsCell.self)
    if dataArray.count > 0 {
      cell.title = (self.dataArray[indexPath.row] as! AwardsModel).content ?? ""
    }
    cell.selectionStyle = .none
    return cell
  }
  
}
