//
//  BlogItemVerticalLayoutCell.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/5.
//

import UIKit

class BlogItemVerticalLayoutCell: UITableViewCell {

  @IBOutlet weak var tagView: TTGTagCollectionView!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
