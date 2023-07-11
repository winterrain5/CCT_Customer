//
//  WalletDetailCardUserOrOwenrCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/7.
//

import UIKit

enum CardBelongType {
  case Owner // 朋友的卡
  case User // 谁绑了我的卡
}

class WalletDetailCardUserOrOwenrCell: UITableViewCell {

  @IBOutlet weak var removeButton: UIButton!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var arrowImageView: UIImageView!
  var removeHandler:((CardOwnerModel)->())?
  var type:CardBelongType = .User {
    didSet {
      if type == .Owner {
        arrowImageView.isHidden = true
        removeButton.isHidden = false
      }else {
        arrowImageView.isHidden = false
        removeButton.isHidden = true
      }
    }
  }
  var model:CardOwnerModel? {
    didSet {
      phoneLabel.text = model?.mobile ?? ""
      if type == .User {
        if model?.status == "0" || model?.status == "2"{
          nameLabel.text = model?.owner_remark
        } else {
          nameLabel.text = (model?.first_name ?? "") + " " + (model?.last_name ?? "")
        }
        
      } else {
        nameLabel.text = (model?.first_name ?? "") + " " + (model?.last_name ?? "")
      }
    }
  }
  @IBAction func removeAction(_ sender: Any) {
    
    removeHandler?(model!)
    
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
