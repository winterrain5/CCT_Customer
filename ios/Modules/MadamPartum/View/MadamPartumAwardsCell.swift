//
//  MadamPartumAwardsCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/21.
//

import UIKit

class MadamPartumAwardsCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  var title:String = "" {
    didSet {
      titleLabel.text = title
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
