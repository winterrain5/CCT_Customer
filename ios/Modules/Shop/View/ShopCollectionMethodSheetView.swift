//
//  ShopCollectionMethodSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/4/24.
//

import UIKit

class ShopCollectionMethodSheetView: UIView,UITableViewDelegate,UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  var selectedIndex = IndexPath(row: 0, section: 0)
  var emptyString:NSAttributedString = {
    let str = "No Collection Method"
    let attr = NSMutableAttributedString(string: str)
    attr.addAttribute(.font, value: UIFont(name:.AvenirNextRegular,size:16), range: NSRange(location: 0, length: str.count))
    return attr
  }()
  var shouldDisplay = false
  var localDeliveryMethod:ShopCollectionModel! {
    didSet {
      localDeliveryMethod.isSelected = true
      self.dataArray.append(localDeliveryMethod)
      getCanSendProductLocations()
    }
  }
  var dataArray:[ShopCollectionModel] = []
  var selectCompleteHandler:((ShopCollectionModel)->())?
  override func awakeFromNib() {
    super.awakeFromNib()
       
    tableView.separatorStyle = .none
    tableView.register(cellWithClass: ShopCollectionMethodCell.self)
    tableView.emptyDataView { view in
      view.detailLabelString(self.emptyString)
      view.shouldDisplay(self.shouldDisplay)
    }
    
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }
  
  func getCanSendProductLocations() {
    
    let params = SOAPParams(action: .Company, path: .getCanSendProductLocations)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ShopCollectionModel.self, from: data) {
        self.shouldDisplay = false
        models.forEach({ $0.delivery_fee = "0" })
        self.dataArray.append(contentsOf: models)
        self.reloadData()
      }else {
        self.shouldDisplay = true
        self.reloadData()
      }
      
    } errorHandler: { e in
      self.shouldDisplay = true
      self.reloadData()
    }

  }
  
  func reloadData() {
    tableView.reloadData()
    tableView.reloadEmptyDataView()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 48
  }
  

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: ShopCollectionMethodCell.self)
    cell.selectionStyle = .none
    if dataArray.count > 0  {
      cell.model = dataArray[indexPath.row]
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dataArray[selectedIndex.row].isSelected = false
    dataArray[indexPath.row].isSelected = true
    selectedIndex = indexPath
    
    reloadData()
  }
  
  @IBAction func selectButtonAction(_ sender: Any) {
    selectCompleteHandler?(dataArray[selectedIndex.row])
    EntryKit.dismiss()
  }
  func show(selecteComplete:@escaping (ShopCollectionModel)->()) {
    selectCompleteHandler = selecteComplete
    EntryKit.display(view: self, size: CGSize(width: kScreenWidth, height: 418), style: .sheet)
  }
}

class ShopCollectionMethodCell:UITableViewCell {
  
  var model:ShopCollectionModel! {
    didSet {
      if model.isSelected {
        nameLabel.textColor = R.color.theamRed()
        nameLabel.backgroundColor = R.color.grayf2()
      }else {
        nameLabel.textColor = R.color.grayBD()
        nameLabel.backgroundColor = R.color.white()
      }
      if model.id == "-1" {
        nameLabel.text = model.text
      }else {
        nameLabel.text = "Self-Collection @ \(model.text)"
      }
      
    }
  }
  var nameLabel = UILabel().then { label in
    label.font = UIFont(name: .AvenirNextDemiBold, size:16)
    label.cornerRadius = 16
    label.textAlignment = .center
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(nameLabel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    nameLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
