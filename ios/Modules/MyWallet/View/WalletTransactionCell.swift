//
//  WalletTransactionCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/3.
//

import UIKit

class WalletTransactionCell: UITableViewCell {

  @IBOutlet weak var invoiceNoLabel: UILabel!
  @IBOutlet weak var productNameLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  @IBOutlet weak var pointsLabel: UILabel!
  
  var model:WalletTranscationModel! {
    didSet {
      invoiceNoLabel.text = "#" + (model.invoice_no ?? "")
      
      if model.product_category != "9" {
        productNameLabel.text = model.first_product_alias_name
      }else {
        productNameLabel.text = "Top Up"
      }
      
      priceLabel.text = ((model.total?.float() ?? 0) + (model.freight?.float() ?? 0)).string.formatMoney().dolar
      
      pointsLabel.isHidden = true
    }
  }
  

  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
