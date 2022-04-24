//
//  WalletPaymentMethodCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit

class WalletPaymentMethodCell: UITableViewCell {

  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var typeImgView: UIImageView!
  @IBOutlet weak var checkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  var model:MethodLines! {
    didSet {
      if model.type == 0 { // 自己的余额
        amountLabel.isHidden = false
        deleteButton.isHidden = true
        amountLabel.text = model.amount.formatMoney().dolar
        typeImgView.image = R.image.payment_card()
      }
      
      if model.type == 1 { // 自己的卡
        amountLabel.isHidden = true
        deleteButton.isHidden = false
        typeImgView.image = R.image.transaction_payment_other()
      }
      
      if model.type == 2 { // 朋友的卡
        amountLabel.isHidden = false
        deleteButton.isHidden = true
        amountLabel.text = model.amount.formatMoney().dolar
        typeImgView.image = R.image.transaction_payment_other()
      }
      
      nameLabel.text = model.name_on_card
      checkImageView.isHidden = !(model.isSelected ?? false)
    }
  }
  var deleteHandler:((MethodLines)->())?
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  @IBAction func deleteAction(_ sender: Any) {
    self.deleteHandler?(self.model)
  }
}
