//
//  BlogFilterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/10.
//

import UIKit

class BlogFilterView: UIView,UITableViewDelegate,UITableViewDataSource {

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
  private var datas:[BlogFilterLabel] = []
  private var tableView:UITableView?
  private var updateComplete:(([BlogFilterLabel])->())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(titleLabel)
    configTableview(.plain)
    
    EntryKit.dismissHandler = {
      self.updateComplete?(self.datas)
    }
    
    rx.anyGesture(.tap()).when(.recognized).subscribe(onNext:{ _ in
      EntryKit.dismiss()
    }).disposed(by: rx.disposeBag)
  }
  
  func configData(users:[BlogFilterLabel],all:[BlogFilterLabel]) {
    if users.isEmpty {
      all.forEach({ $0.is_on = true })
      datas = all
    }else {
      all.forEach { allItem in
        allItem.is_on = users.contains(where: { allItem.id == $0.id })
      }
      datas = all
    }
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
    
    tableView?.register(cellWithClass: BlogFilterCell.self)
  }
  
  func updateFilters(_ model:BlogFilterLabel) {
    let params = SOAPParams(action: .Blog, path: API.saveClientBlogFilters)
    let data = SOAPDictionary()
    
    var updatefilter = datas
    updatefilter.removeAll(where: { $0.is_on == false })
    for (i,item) in updatefilter.enumerated() {
      data.set(key: i.string, value: item.id ?? "")
    }
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
     
    } errorHandler: { e in
      EntryKit.dismiss()
    }
    
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
  
  
  static func show(with users:[BlogFilterLabel],all:[BlogFilterLabel],complete:(([BlogFilterLabel])->())?) {
    let view = BlogFilterView()
    view.configData(users: users, all: all)
    view.updateComplete = complete
    let height = (view.datas.count * 50).cgFloat + 150 + kBottomsafeAreaMargin
    let realHeight = height >= kScreenHeight * 0.7 ? kScreenHeight * 0.7 : height
    let size = CGSize(width: kScreenWidth, height: realHeight)
    EntryKit.display(view: view, size: size, style: .sheet, backgroundColor: R.color.blackAlpha8()!, touchDismiss: true)
  }
  

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return datas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BlogFilterCell.self)
    cell.selectionStyle = .none
    if datas.count > 0 {
      cell.model = datas[indexPath.row]
    }
    cell.switchHandler = { [weak self] model in
      self?.updateFilters(model)
    }
    return cell
  }
  

}

class BlogFilterCell: UITableViewCell {
  private var titleLabel = UILabel().then { label in
    label.text = "Filter"
    label.textColor = R.color.black()
    label.font = UIFont(name:.AvenirNextRegular,size:14)
    label.lineHeight = 20
  }
  private var switchControl = UISwitch().then { view in
    view.onTintColor = R.color.theamBlue()
  }
  var switchHandler:((BlogFilterLabel)->())?
  var model:BlogFilterLabel! {
    didSet {
      titleLabel.text = model.key_word
      switchControl.isOn = model.is_on ?? true
    }
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(titleLabel)
    contentView.addSubview(switchControl)
    switchControl.addTarget(self, action: #selector(switchControlAction(_:)), for: .valueChanged)
  }
  
  @objc func switchControlAction(_ sender:UISwitch) {
    model.is_on?.toggle()
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
