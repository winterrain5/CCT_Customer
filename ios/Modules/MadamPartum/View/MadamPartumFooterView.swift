//
//  MadamPartumFooterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit

class MadamPartumFooterView: UIView,UITableViewDelegate,UITableViewDataSource {
  
  @IBOutlet weak var tableContentView: UIView!
  
  var tableView:UITableView!
  var updateHandler:((CGFloat)->())?
  var datas:[MadamPartumLocationModel] = [] {
    didSet {
      
      tableView.reloadData()
      
      let tableH = (datas.count * 376).cgFloat
      updateHandler?(tableH + 460)
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    configTableview(.plain)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func configTableview(_ style:UITableView.Style) {
    
    tableView = UITableView.init(frame: .zero, style: style)
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.allowsSelection = false
    tableView.isScrollEnabled = false
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    tableView.tableFooterView = UIView.init()
    
    tableView.rowHeight = 376
    tableView.estimatedSectionFooterHeight = 0
    tableView.estimatedSectionHeaderHeight = 0
    //
    
    tableContentView.addSubview(tableView)
    
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.register(nibWithCellClass: MadamPartumLocationCell.self)
    
  }
  

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return datas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: MadamPartumLocationCell.self)
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
    }
    return cell
  }
  
  @IBAction func readMoreButtonAction(_ sender: Any) {
    let vc = MadamPartumStoryController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
  
  @IBAction func needMoreHelpButtonAction(_ sender: Any) {
    let vc = QuestionHelperController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
}
