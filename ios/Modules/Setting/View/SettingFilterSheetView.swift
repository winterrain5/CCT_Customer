//
//  SettingFilterSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/28.
//

import UIKit


class SettingFilterSheetView: UIView,UITableViewDelegate,UITableViewDataSource {

  private var titleLabel = UILabel().then { label in
    label.text = "Filter"
    label.textColor = R.color.theamBlue()
    label.font = UIFont(name: .AvenirNextDemiBold, size:16)
    label.lineHeight = 28
  }
  private var headerLine = UIView().then({ view in
    view.backgroundColor = R.color.placeholder()
    view.size = CGSize(width: kScreenWidth - 32, height: 1)
  })
  private var datas:[SettingFilterModel] = []
  private var tableView:UITableView?
  private var updateComplete:(([SettingFilterModel])->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(titleLabel)
    configTableview(.plain)
    EntryKit.dismissHandler = { [weak self] in
      guard let `self` = self else { return }
      self.updateComplete?(self.datas)
    }
  }
  
  func configData(users:[SettingFilterModel]) {
    datas = users
    self.tableView?.reloadData()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }
  
  func configTableview(_ style:UITableView.Style) {
    
    tableView = UITableView.init(frame: .zero, style: style)
    
    tableView?.delegate = self
    tableView?.dataSource = self
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    tableView?.separatorColor = R.color.line()
    tableView?.backgroundColor = .white
    tableView?.showsHorizontalScrollIndicator = false
    tableView?.showsVerticalScrollIndicator = false
    tableView?.tableFooterView = UIView.init()
    tableView?.tableHeaderView = headerLine
    tableView?.estimatedRowHeight = 0
    tableView?.estimatedSectionFooterHeight = 0
    tableView?.estimatedSectionHeaderHeight = 0
    //
    tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
    tableView?.rowHeight = 50
    addSubview(tableView!)
    
    tableView?.register(cellWithClass: SettingFilterCell.self)
  }
  
 
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners:  [.topLeft,.topRight], radii: 16)
    titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(24)
    }
    tableView?.snp.makeConstraints({ make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(32)
    })
  }
  
  
  static func show(with users:[SettingFilterModel],title:String, complete:(([SettingFilterModel])->())?) {
    let view = SettingFilterSheetView()
    view.titleLabel.text = title
    view.configData(users: users.sorted(by: { $0.id < $1.id }))
    view.updateComplete = complete
    let height = (view.datas.count * 50).cgFloat + 150 + kBottomsafeAreaMargin
    let size = CGSize(width: kScreenWidth, height: height)
    EntryKit.displayView(asSheet: view, size: size)
  }
  

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return datas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: SettingFilterCell.self)
    cell.selectionStyle = .none
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
    }
    
    return cell
  }
  

}

class SettingFilterCell: UITableViewCell {
  private var titleLabel = UILabel().then { label in
    label.text = "Filter"
    label.textColor = R.color.black()
    label.font = UIFont(name:.AvenirNextRegular,size:14)
    label.lineHeight = 20
  }
  private var switchControl = UISwitch().then { view in
    view.onTintColor = R.color.theamBlue()
  }
  var switchHandler:((SettingFilterModel)->())?
  var model:SettingFilterModel! {
    didSet {
      titleLabel.text = model.key_word
      switchControl.isOn = model.is_on
    }
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(titleLabel)
    contentView.addSubview(switchControl)
    switchControl.addTarget(self, action: #selector(switchControlAction(_:)), for: .valueChanged)
  }
  
  @objc func switchControlAction(_ sender:UISwitch) {
    model.is_on.toggle()
    switchHandler?(model)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(16)
    }
    switchControl.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-16)
    }
    switchControl.transform = CGAffineTransform.init(scaleX: 0.6, y: 0.6)
  }
}
