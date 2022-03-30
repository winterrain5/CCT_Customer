//
//  WalletBaseController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/2.
//

import UIKit
import JXPagingView
class WalletBaseController: BaseTableController {

  var listViewDidScrollCallback: ((UIScrollView) -> ())?

  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }
  

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
      self.listViewDidScrollCallback?(scrollView)
  }

}

extension WalletBaseController: JXPagingViewListViewDelegate {
    override func listView() -> UIView {
        return view
    }

    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }

    func listScrollView() -> UIScrollView {
        return self.tableView!
    }

}



