//
//  ServiceDetailHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit

class ServiceDetailHeaderView: UIView,UITableViewDelegate,UITableViewDataSource {

  @IBOutlet weak var imageView: UIImageView!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var summaryDescLabel: UILabel!
  
  @IBOutlet weak var dowhatTitleLabel: UILabel!
  @IBOutlet weak var dowhatDescLabel: UILabel!
  
  @IBOutlet weak var tableContentView: UIView!
  @IBOutlet weak var tableConteHCons: NSLayoutConstraint!
  
  var tableView:UITableView!
 
  var updateHandler:((CGFloat)->())?
  var model:ServiceDetailBrifeModel? {
    didSet {
      imageView.yy_setImage(with: model?.briefData?.part1_thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
      titleLabel.text = model?.briefData?.title
      summaryDescLabel.text = model?.briefData?.summary_desc
      
      dowhatTitleLabel.text = model?.briefData?.do_what_title
      dowhatDescLabel.text = model?.briefData?.do_what
      
      hideSkeleton()
      
      self.tableView.reloadData()
    
      let tableH = model?.approaches?.reduce(0, {
        $0 + (190 + ($1.description?.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont(.AvenirNextRegular,16)) ?? 0))
      }) ?? 0
      self.tableConteHCons.constant = tableH
      let totalH = self.titleLabel.requiredHeight + self.summaryDescLabel.requiredHeight + self.dowhatTitleLabel.requiredHeight + self.dowhatDescLabel.requiredHeight + tableH + 395.cgFloat
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
    tableView.backgroundColor = .white
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    tableView.tableFooterView = UIView.init()
    
    tableView.estimatedSectionFooterHeight = 0
    tableView.estimatedSectionHeaderHeight = 0
    //
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
    
    tableContentView.addSubview(tableView!)
    
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.register(nibWithCellClass: ServiceDetailApproachCell.self)
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if model?.approaches?.count ?? 0 > 0 {
      let item = model?.approaches?[indexPath.row]
      return 190 + (item?.description?.heightWithConstrainedWidth(width: kScreenWidth - 32, font: UIFont(.AvenirNextRegular,16)) ?? 0)
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return model?.approaches?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ServiceDetailApproachCell.self)
    if model?.approaches?.count ?? 0 > 0 {
      cell.model = model?.approaches?[indexPath.row]
    }
    return cell
  }
  
}
