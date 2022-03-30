//
//  DataProtectionModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/1.
//

import UIKit

class DataProtectionModel {
  var id:Int
  var title:String
  var content:String
  var rowHeight:CGFloat {
    get {
      let h1 = title.heightWithConstrainedWidth(width: kScreenWidth - 48, font: UIFont(.AvenirNextDemiBold,16))
      let h2 = content.heightWithConstrainedWidth(width: kScreenWidth - 48, font: UIFont(.AvenirNextRegular,16))
      return h1 + h2 + 64
    }
  }
  init(title:String,content:String,id:Int) {
    self.title = title
    self.content = content
    self.id = id
  }
}
