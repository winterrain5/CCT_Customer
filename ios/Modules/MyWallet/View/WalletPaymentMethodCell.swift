//
//  WalletPaymentMethodCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit

class WalletPaymentMethodCell: UITableViewCell {

  @IBOutlet weak var checkImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  var model:MethodLines! {
    didSet {
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
