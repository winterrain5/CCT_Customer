//
//  CheckInTodaySessionView.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/14.
//

import UIKit
import CHIPageControl
class CheckInTodaySessionView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {

  @IBOutlet weak var registerServiceContentView: UIView!
  @IBOutlet weak var clvContentView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var timeLabel2: UILabel!
  @IBOutlet weak var titleLabel2: UILabel!
  @IBOutlet weak var waitTimeLabel: UILabel!
  
  @IBOutlet weak var registerButton: LoadingButton!
  var itemWidth:CGFloat = 0
  var outlet:(id:String,name:String)? {
    didSet {
      titleLabel.text = "Registering for today at \(outlet?.name ?? "")"
    }
  }
  var models:[BookingTodayModel] = [] {
    didSet {
      pageControl.isHidden = models.count == 0
      itemWidth = models.count > 1 ? 200 : (kScreenWidth - 48).int.cgFloat
      let itemHeight = 184.cgFloat~
      layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
      collectionView.reloadData()
      pageControl.numberOfPages = models.count
      
      if models.count == 0 {
        self.getWaitInfo()
        registerServiceContentView.isHidden = false
      }else {
        self.hideSkeleton()
        registerServiceContentView.isHidden = true
      }
      
      
    }
  }
  
  lazy var layout = PagingCollectionViewLayout().then { layout in
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    layout.minimumLineSpacing = 16
    layout.minimumInteritemSpacing = 0
  }
  
  lazy var collectionView:UICollectionView = {
    let view = UICollectionView(frame: .zero,collectionViewLayout: layout)
    view.showsHorizontalScrollIndicator = false
    view.backgroundColor = .clear
    view.delegate = self
    view.dataSource = self
    view.decelerationRate = .fast
    return view
  }()
  var pageControl = CHIPageControlJaloro().then { pageControl in
    pageControl.currentPageTintColor = R.color.white()?.withAlphaComponent(0.8)
    pageControl.tintColor = R.color.white()?.withAlphaComponent(0.2)
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.hidesForSinglePage = true
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    clvContentView.addSubview(collectionView)
    collectionView.register(nibWithCellClass: CheckInTodayCell.self)
    addSubview(pageControl)
    
    timeLabel.text = Date().string(withFormat: "dd MMMM yyyy,EEE")
    
    self.showSkeleton()
  }
  
  func getWaitInfo() {
    let params = SOAPParams(action: .BookingOrder, path: .getWaitServiceInfo)
    params.set(key: "locationId", value: outlet?.id ?? "")
    params.set(key: "startTime", value: Date().string(withFormat: "yyyy-MM-dd"))
    params.set(key: "endTime", value: Date().adding(.day, value: 1).string(withFormat: "yyyy-MM-dd"))
    params.set(key: "wellnessTreatType", value: 2)
    NetworkManager().request(params: params) { data in
      if let model = DecodeManager.decodeObjectByHandJSON(WaitServiceModel.self, from: data) {
        
        let sub1 = "\(model.queue_count) in queue -Est. "
        let str = "\(model.queue_count)  in queue -Est. \(model.duration_mins) mins waiting time"
        let attr = NSMutableAttributedString(string: str)
        attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size: 14), range: NSRange(location: 0, length: model.queue_count.count))
        attr.addAttribute(.font, value: UIFont(name: .AvenirNextDemiBold, size: 14), range: NSRange(location: sub1.count, length: (model.duration_mins + " mins").count))
      }
      self.hideSkeleton()
    } errorHandler: { e in
      self.hideSkeleton()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    pageControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(clvContentView.snp.bottom).offset(32)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: CheckInTodayCell.self, for: indexPath)
    if models.count > 0 {
      cell.model = models[indexPath.item]
      
      cell.checkInHandler = { model in
        let vc = ConfirmSessionController(todayModel: model)
        UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
      }
    }
    return cell
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x == 0 {
      pageControl.set(progress: 0, animated: true)
    }else {
      let page = ceil((scrollView.contentOffset.x / (itemWidth + 16)))
      pageControl.set(progress: page.int, animated: true)
    }
  }
  
  
  @IBAction func registerSessionAction(_ sender: LoadingButton) {
    getCancelCount(0)
  }
  
  @IBAction func treatmentServiceAction(_ sender: Any) {
    getCancelCount(1)
  }
  @IBAction func wellnessServiceAction(_ sender: Any) {
    
    getCancelCount(2)
  }
  
  func getCancelCount(_ wellnessTreatment:Int) {
    let params = SOAPParams(action: .Client, path: .getClientCancelCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      let count = JSON.init(from: data)?["cancel_count"].rawString()?.int ?? 0
      if count >= 3 {
        AlertView.show(message: "If you delay cancelling more than 3 times, your in app reservation permission will be suspended.")
      }else {
        if wellnessTreatment == 0 {
          SelectTypeOfServiceSheetView.show()
        }
        if wellnessTreatment == 1 { //
          let vc = BookingAppointmentController(type: .Treatment)
          UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
        }
        if wellnessTreatment == 2 {
          WellnessAppointmentTypeSelectShetView.show()
        }
      }
     
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
}
