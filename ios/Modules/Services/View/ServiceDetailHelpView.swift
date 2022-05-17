//
//  ServiceDetailHelpView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit

class ServiceDetailHelpView: UIView,UITableViewDelegate,UITableViewDataSource  {

   
  @IBOutlet weak var tableContentView: UIView!
  var tableView:UITableView!
 
  var updateHandler:((CGFloat)->())?
  
  var helps:[BriefHelpItems] = [] {
    didSet {
      self.tableView.reloadData()
    
      let tableH = helps.reduce(0, {
        $0 + self.caculateCellHeight($1)
      })
      let totalH = tableH + 150.cgFloat
      self.updateHandler?(totalH)
     
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    showSkeleton()
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
    tableView.separatorColor = .clear
    tableView.backgroundColor = .clear
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    tableView.tableFooterView = UIView.init()
    
    tableView.estimatedSectionFooterHeight = 0
    tableView.estimatedSectionHeaderHeight = 0
    //
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
    
    tableContentView.addSubview(tableView!)
    
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.register(nibWithCellClass: ServiceDetailHelpCell.self)
    
  }
  
  func caculateCellHeight(_ item:BriefHelpItems) -> CGFloat{
    let h1 = (item.description?.heightWithConstrainedWidth(width: kScreenWidth - 119, font: UIFont(name:.AvenirNextRegular,size:16)) ?? 0)
    let h2 = (item.title?.heightWithConstrainedWidth(width: kScreenWidth - 119, font: UIFont(name: .AvenirHeavy,size: 18)) ?? 0)
    
    return 30 + h1 + h2
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if helps.count > 0 {
      let item = helps[indexPath.row]
      return caculateCellHeight(item)
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return helps.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ServiceDetailHelpCell.self)
    if helps.count > 0 {
      cell.model = helps[indexPath.row]
    }
    return cell
  }
  
  
}
