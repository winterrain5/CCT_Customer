//
//  MadamPartumHeaderView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/19.
//

import UIKit
import CHIPageControl
class MadamPartumHeaderView: UIView,FSPagerViewDelegate,FSPagerViewDataSource {
  
  @IBOutlet weak var pageControl: CHIPageControlJaloro!
  @IBOutlet weak var bannerContentView: UIView!
  lazy var pagerView = FSPagerView().then { view in
    view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
    view.delegate = self
    view.dataSource = self
    view.isInfinite = true
    view.automaticSlidingInterval = 3
    
  }
  var datas:[BlogModel] = [] {
    didSet {
      pagerView.reloadData()
      pageControl.numberOfPages = datas.count
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    
    pageControl.currentPageTintColor = UIColor(hexString: "#EE8F7B")
    pageControl.tintColor = UIColor(hexString: "#EE8F7B")?.withAlphaComponent(0.2)
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.progress = 0
    
    bannerContentView.addSubview(pagerView)
    bannerContentView.bringSubviewToFront(pageControl)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    pagerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  @IBAction func bookAppointmentButtonAction(_ sender: Any) {
    let params = SOAPParams(action: .Client, path: .getClientCancelCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      let count = JSON.init(from: data)?["cancel_count"].rawString()?.int ?? 0
      if count >= 3 {
        AlertView.show(message: "If you delay cancelling more than 3 times, your in app reservation permission will be suspended.")
      }else {
        SelectTypeOfServiceSheetView.show()
      }
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
  
  public func numberOfItems(in pagerView: FSPagerView) -> Int {
    return datas.count
  }
  
  public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
    let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
    if datas.count > 0 {
      cell.imageView?.yy_setImage(with: datas[index].thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
    }
    cell.imageView?.contentMode = .scaleAspectFill
    cell.imageView?.isUserInteractionEnabled = true
    return cell
  }

  func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
    return true
  }
  func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
    pagerView.deselectItem(at: index, animated: false)
    let model = datas[index]
    let vc = BlogDetailViewController(blogId: model.id ?? "", hasBook: model.has_booked)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }

  func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
    pageControl.set(progress: index, animated: true)
  }
}
