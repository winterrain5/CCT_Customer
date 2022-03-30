//
//  MyOrderListCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/17.
//

import UIKit

class MyOrderListCell: UITableViewCell {
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var productsLabel: UILabel!
  var model:MyOrderModel! {
    didSet {
      let attr = NSMutableAttributedString()
      model.order_lines?.forEach({ product in
        attr.append(self.createProductInfo(product.qty?.removingSuffix(".00") ?? "", product.name ?? ""))
      })
      productsLabel.attributedText = attr
      
      let dateStr = "Date of Order ".appending(model.invoice_date?.date(withFormat: "yyyy-MM-dd")?.string(withFormat: "dd MMM yyyy,EEE") ?? "")
      dateLabel.text = dateStr
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func createProductInfo(_ count:String,_ name:String) -> NSMutableAttributedString {
    let str = "\(count) x " + name + "\n"
    let attr = NSMutableAttributedString(string: str)
    attr.addAttribute(.font, value: UIFont(.AvenirNextRegular,14), range: NSRange(location: 0, length: str.count - name.count - 1))
    attr.addAttribute(.font, value: UIFont(.AvenirNextDemiBold,14), range: NSRange(location: str.count - name.count, length: name.count))
    return attr
  }
  
}
