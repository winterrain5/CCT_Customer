//
//  TierPrivilegesController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/8.
//

import UIKit

class TierPrivilegesController: BaseTableController {
  var footerView = WalletDetailFooterView(title: "View Terms & Conditions", isNeedArrow: false)
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigation.item.title = "Tier Privileges"
    
    let model = TierListModel(tierLevel: "Basic Tier", tierDesc: "Begin your journey by making your purchases and top up through this card, you'll be able to earn points and progress to another tier!", level: "Basic", amount: "0", privileges: NSMutableAttributedString(string: ""), id: 1,cellHeight: 280)
    
    self.dataArray.append(model)
    getNewCardDiscountsByLevel(2)
    getNewCardDiscountsByLevel(3)
    getNewCardDiscountsByLevel(4)
  }
  
  func getNewCardDiscountsByLevel(_ level:Int) {
    let params = SOAPParams(action: .CardDiscountContent, path: .getCardDiscountDetails)
    params.set(key: "levelId", value: level.string)
    
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeByCodable(CardDiscountDetailModel.self, from: data) {
        let privileges = NSMutableAttributedString(string: "")
        
        let attr1 = NSMutableAttributedString(string: "· \(model.r_discount1 ?? "")\n")
        attr1.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size:16), range: NSRange(location: 0, length: 1))
        attr1.addAttribute(.font, value: UIFont(name:.AvenirNextRegular,size:14), range: NSRange(location: 1, length: attr1.string.count - 1))
        privileges.append(attr1)
        
        let attr2 = NSMutableAttributedString(string: "· \(model.r_discount2 ?? "")\n")
        attr2.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size:16), range: NSRange(location: 0, length: 1))
        attr2.addAttribute(.font, value: UIFont(name:.AvenirNextRegular,size:14), range: NSRange(location: 1, length: attr2.string.count - 1))
        privileges.append(attr2)
        
        let attr3 = NSMutableAttributedString(string: "· \(model.r_discount3 ?? "")\n")
        attr3.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size:16), range: NSRange(location: 0, length: 1))
        attr3.addAttribute(.font, value: UIFont(name:.AvenirNextRegular,size:14), range: NSRange(location: 1, length: attr3.string.count - 1))
        privileges.append(attr3)
        
        
        let constraintRect = CGSize(width: kScreenWidth - 88, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = privileges.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        
        let cellHeight:CGFloat = boundingBox.height + 344
        
        if level == 2 {
          let model = TierListModel(tierLevel: "Silver Tier", tierDesc: "Spend or Top up an accumulated amount of $500 to attained this member tier", level: "Silver", amount: "500", privileges: privileges, id: level,cellHeight: cellHeight)
          self.dataArray.append(model)
        }
        if level == 3 {
          let model = TierListModel(tierLevel: "Gold Tier", tierDesc: "Spend or Top up an accumulated amount of $1000 to attained this member tier", level: "Gold", amount: "1000", privileges: privileges, id: level,cellHeight: cellHeight)
          self.dataArray.append(model)
        }
        if level == 4 {
          let model = TierListModel(tierLevel: "Platinum Tier", tierDesc: "Spend or Top up an accumulated amount of $2000 to attained this member tier", level: "Platinum", amount: "2000", privileges: privileges, id: level,cellHeight: cellHeight)
          self.dataArray.append(model)
        }
        self.dataArray = (self.dataArray as! [TierListModel]).sorted(by: { $0.id < $1.id })
        self.tableView?.reloadData()
      }
    } errorHandler: { e in
      
    }
    
  }
  
  
  override func createListView() {
    super.createListView()
    
    tableView?.separatorStyle = .singleLine
    tableView?.separatorInset = .zero
    tableView?.separatorColor = R.color.line()
    
    tableView?.tableFooterView = footerView
    footerView.size = CGSize(width: kScreenWidth, height: 72)
    
    tableView?.register(nibWithCellClass: TierPrivilegesCell.self)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let model = self.dataArray[indexPath.row] as? TierListModel
    return model?.cellHeight ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = TierPrivilegesCell.loadViewFromNib()
    cell.model = self.dataArray[indexPath.row] as? TierListModel
    cell.selectionStyle = .none
    return cell
  }
  
}
