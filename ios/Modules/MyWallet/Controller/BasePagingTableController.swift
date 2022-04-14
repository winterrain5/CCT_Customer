//
//  WalletBaseController.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/2.
//

import UIKit
import JXPagingView
import JXSegmentedView
class BasePagingTableController: BaseTableController {

  var listViewDidScrollCallback: ((UIScrollView) -> ())?

  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }
  

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
      self.listViewDidScrollCallback?(scrollView)
  }

}

extension BasePagingTableController: JXPagingViewListViewDelegate {
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



extension BaseViewController: JXSegmentedListContainerViewListDelegate {
  func listView() -> UIView {
    return view
  }
}

