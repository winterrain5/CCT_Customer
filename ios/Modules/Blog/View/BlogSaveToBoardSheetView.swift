//
//  BlogSaveToBoardSheetView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import UIKit

class BlogSaveToBoardSheetView: UIView,UITableViewDataSource,UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewHCons: NSLayoutConstraint!
  var viewHeight:CGFloat {
    return CGFloat(boards.count * 50 + 145 + 20) + kBottomsafeAreaMargin
  }
  var createBoardHandler:(()->())?
  var selectBoardHandler:((BlogBoardModel)->())?
  var boards:[BlogBoardModel] = [] {
    didSet {
      tableViewHCons.constant = CGFloat(boards.count * 50)
      tableView.reloadData()
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    tableView.tableFooterView = UIView()
    tableView.register(cellWithClass: BlogBoardCell.self)
    tableView.isScrollEnabled = false
    tableView.rowHeight = 50
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    corner(byRoundingCorners: [.topLeft,.topRight], radii: 16)
  }

  @IBAction func createBoardButtonAction(_ sender: Any) {
    createBoardHandler?()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    boards.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withClass: BlogBoardCell.self)
    if boards.count > 0 {
      cell.nameLabel.text = boards[indexPath.row].name
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    self.selectBoardHandler?(boards[indexPath.row])
  }
  
}

class BlogBoardCell:UITableViewCell {
  var nameLabel = UILabel().then { label in
    label.textColor = .black
    label.font = UIFont(name:.AvenirNextRegular,size:14)
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
      make.left.top.bottom.equalToSuperview()
    }
  }
}
