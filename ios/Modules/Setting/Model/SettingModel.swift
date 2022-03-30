//
//  SettingModel.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/28.
//

import UIKit

class SettingModel {
  var title:String
  var descption:String
  var isSwitch:Bool
  var isOn:Bool
  var originValue:String
  init(title:String,descption:String,isSwitch:Bool,isOn:Bool = false,originValue:String = "") {
    self.title = title
    self.descption = descption
    self.isSwitch = isSwitch
    self.isOn = isOn
    self.originValue = originValue
  }
}
