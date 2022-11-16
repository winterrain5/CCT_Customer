//
//  EntryKit.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/11/14.
//

import Foundation

extension EntryKit {
//  EntryKit.displayView(asSheet: view, size: size)
  static func displayView(asSheet view: UIView, size:CGSize) {
    EntryKit.display(view: view, size: size, style: .sheet)
  }
 
}
