//
//  OnBoardViewController.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/21.
//

import UIKit
import CHIPageControl
class OnBoardViewController: BaseCollectionController {
  var pageControl = CHIPageControlJaloro().then { pageControl in
    pageControl.currentPageTintColor = R.color.theamBlue()!
    pageControl.tintColor = R.color.grayBD()?.withAlphaComponent(0.2)
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.hidesForSinglePage = true
    pageControl.numberOfPages = 4
  }
  var nextButton = UIButton().then { btn in
    btn.backgroundColor = R.color.theamRed()
    btn.titleLabel?.font = UIFont(name: .AvenirNextDemiBold, size: 14)
    btn.cornerRadius = 22
    btn.titleColorForNormal = .white
    btn.titleForNormal = "Next"
  }
  var borads:[OnBoardModel] = [
    OnBoardModel(title: "Efficient Booking", image: R.image.onboardingbooking(), desc: "Skip the queue and cumbersome phone conversation. Scheduling an appointment with us is now a few taps away."),
    OnBoardModel(title: "Be the first to receive amazing deals", image: R.image.onboardingvoucher(), desc: "Be instantly informed when we have amazing deals. Enjoy incredible savings for your long term wellness needs."),
    OnBoardModel(title: "Keep track of your Progress", image: R.image.onboardingprogress(), desc: "Manage your appointments, be reminded of upcoming ones and revisit your consultation notes from your previous sessions."),
    OnBoardModel(title: "Gain Loyalty Points", image: R.image.onboardingloyalty(), desc: "Be rewarded on your health and wellness journey with us. Track and redeem your loyalty points at your fingertips.")
  ]
  var row:Int = 0
  override func viewDidLoad() {
    super.viewDidLoad()
   
    nextButton.rx.tap.subscribe(onNext:{ [weak self] in
      guard let `self` = self else { return }
      if self.row == 3 {
        let rootViewController = LoginViewController()
        let nav = BaseNavigationController(rootViewController: rootViewController)
        UIApplication.shared.keyWindow?.rootViewController = nav
        return
      }
      self.row += 1
      if self.row == 3 {
        self.nextButton.titleForNormal = "Get Start"
      }
      self.collectionView?.isPagingEnabled = false
      self.collectionView?.scrollToItem(at: IndexPath(row: self.row, section: 0), at: .centeredHorizontally, animated: true)
      self.collectionView?.isPagingEnabled = true
      self.pageControl.set(progress: self.row, animated: true)
    }).disposed(by: rx.disposeBag)
    
    self.view.addSubview(nextButton)
    nextButton.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.height.equalTo(44)
      make.bottom.equalToSuperview().inset(kBottomsafeAreaMargin + 40)
    }
    
    self.view.addSubview(pageControl)
    pageControl.snp.makeConstraints { make in
      make.bottom.equalTo(nextButton.snp.top).offset(-32)
      make.left.right.equalToSuperview()
    }
  }
  
  override func createListView() {
    super.createListView()
    collectionView?.isPagingEnabled = true
    collectionView?.register(nibWithCellClass: OnBoardCell.self)
    collectionView?.showsHorizontalScrollIndicator = false
  }
  
  override func listViewFrame() -> CGRect {
    return self.view.bounds
  }
  
  override func listViewLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: kScreenWidth, height: kScreenHeight)
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.scrollDirection = .horizontal
    return layout
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return borads.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: OnBoardCell.self, for: indexPath)
    cell.model = borads[indexPath.item]
    return cell
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x == 0 {
      self.row = 0
      self.nextButton.titleForNormal = "Next"
      pageControl.set(progress: 0, animated: true)
    }else {
      let page = ceil((scrollView.contentOffset.x / kScreenWidth))
      self.row = Int(page)
      pageControl.set(progress: page.int, animated: true)
      
      if page == 3 {
        self.nextButton.titleForNormal = "Get Start"
      }else {
        self.nextButton.titleForNormal = "Next"
      }
    }
  }
}
