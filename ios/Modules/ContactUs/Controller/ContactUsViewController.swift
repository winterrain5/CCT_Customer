//
//  ContactUsViewController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class ContactUsViewController: BaseTableController {
  
  private var selectedIndex:IndexPath?
  private var sendButton = UIButton().then { btn in
    btn.cornerRadius = 22
    btn.backgroundColor = R.color.theamRed()
    btn.titleColorForNormal = .white
    btn.titleLabel?.font = UIFont(.AvenirNextDemiBold,14)
    btn.titleForNormal = "Submit an enquiry"
  }
  private var headerView = UIView().then { view in
    view.backgroundColor = .white
    
    let label = UILabel()
    label.text = "Contact Us"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(.AvenirNextDemiBold,24)
    
    view.addSubview(label)
    label.frame = CGRect(x: 24, y: 32, width: kScreenWidth - 48, height: 36)
  }
  let showIds:[String] = ["99","101","107","105","109","104"]
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.barAppearance(tintColor: .white, barBackgroundColor: R.color.theamBlue()!, image: R.image.return_left(), backButtonTitle: " Back")
    self.view.addSubview(sendButton)
    sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
    sendButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(32)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(40 + kBottomsafeAreaMargin)
    }
    refreshData()
  }
  
  @objc func sendButtonAction() {
    FillInEnquiryFormView.showView(from: self.view)
  }
  
  
  override func refreshData() {
    let params = SOAPParams(action: .Company, path: .getTLocations)
    params.set(key: "pId", value: Defaults.shared.get(for: .companyId) ?? "97")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeByCodable([ContactUsModel].self, from: data) {
        models.forEach({ $0.isExpend = false })
        self.dataArray = models.filter({ self.showIds.contains($0.id ?? "")})
      }
      self.endRefresh()
    } errorHandler: { e in
      self.endRefresh(e.emptyDatatype)
    }
    
  }
  
  override func createListView() {
    super.createListView()
    
    tableView?.register(nibWithCellClass: ContactUsListCell.self)
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 84 + kBottomsafeAreaMargin, right: 0)
    tableView?.tableHeaderView = headerView
    headerView.size = CGSize(width: kScreenWidth, height: 84)
    
    registRefreshHeader()
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if self.dataArray.count > 0 {
      return (self.dataArray[indexPath.row] as! ContactUsModel).cellHeight ?? 76
    }
    return 76
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ContactUsListCell.self)
    if dataArray.count > 0 {
      cell.model = self.dataArray[indexPath.row] as? ContactUsModel
    }
    cell.selectionStyle = .none
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if let sel = selectedIndex, sel.row != indexPath.row{
      let model = self.dataArray[sel.row] as! ContactUsModel
      model.isExpend = false
      model.cellHeight = 76
      
      self.tableView?.reloadRows(at: [sel], with: .automatic)
    }
    
    let model = self.dataArray[indexPath.row] as! ContactUsModel
    model.isExpend!.toggle()
    if model.isExpend! {
      model.cellHeight = 207 + (model.address?.heightWithConstrainedWidth(width: kScreenWidth - 64, font: UIFont(.AvenirNextRegular,16)) ?? 30)
    }else {
      model.cellHeight = 76
    }
   
    selectedIndex = indexPath
    
    self.tableView?.reloadRows(at: [indexPath], with: .automatic)
    
  }
  
}
