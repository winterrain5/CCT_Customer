//
//  ServiceDetailPriceView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/25.
//

import UIKit

class ServiceDetailPriceView: UIView,UITableViewDelegate,UITableViewDataSource {

  @IBOutlet weak var tableContent: UIView!
  var tableView:UITableView!
  var headeLine = UIView().then({ view in
    view.backgroundColor = .white.withAlphaComponent(0.2)
    view.size = CGSize(width: kScreenWidth - 92, height: 1)
  })
  var updateHandler:((CGFloat)->())?
  var durations:[ServiceDurations]? {
    didSet {
      
      tableView.reloadData()
      
      let totalH = ((durations?.count ?? 0) * 104 + 120).cgFloat
      updateHandler?(totalH)
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
    tableView.separatorStyle = .singleLine
    tableView.separatorColor = .white.withAlphaComponent(0.2)
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    tableView.backgroundColor = R.color.theamBlue()
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    tableView.tableFooterView = UIView.init()
    tableView.tableHeaderView = headeLine
    
    tableView.rowHeight = 104
    tableView.estimatedSectionFooterHeight = 0
    tableView.estimatedSectionHeaderHeight = 0
    //
    
    tableContent.addSubview(tableView!)
    
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.register(cellWithClass: ServiceDetailPriceCell.self)
    
  }
  

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return durations?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ServiceDetailPriceCell.self)
    if durations?.count ?? 0 > 0 {
      cell.model = durations?[indexPath.row]
    }
    return cell
  }

}

class ServiceDetailPriceCell: UITableViewCell {
  private var priceLabel = UILabel().then { label in
    label.textColor = .white
    label.font = UIFont(.AvenirHeavy,36)
    label.lineHeight = 44
    label.backgroundColor = .clear
  }
  private var durationLabel = UILabel().then { label in
    label.textColor = .white.withAlphaComponent(0.8)
    label.font = UIFont(.AvenirHeavy,18)
    label.lineHeight = 28
    label.backgroundColor = .clear
  }
  private var timeImageView = UIImageView().then { view in
    view.image = R.image.service_detail_timer()
  }
  var model:ServiceDurations! {
    didSet {
      priceLabel.text = model.retail_price?.dolar
      durationLabel.text = (model.duration ?? "") + " mins"
    }
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = R.color.theamBlue()
    contentView.addSubview(priceLabel)
    contentView.addSubview(durationLabel)
    contentView.addSubview(timeImageView)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    priceLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(30)
      make.centerY.equalToSuperview()
    }
    
    durationLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().inset(30)
      make.centerY.equalToSuperview()
    }
    
    timeImageView.snp.makeConstraints { make in
      make.right.equalTo(durationLabel.snp.left).offset(-6)
      make.centerY.equalToSuperview()
    }
    
  }
}
