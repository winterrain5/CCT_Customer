//
//  HomeContainer.swift
//  CCTIOS
//
//  Created by chengquan zhou on 2022/6/2.
//

import UIKit
import CHIPageControl
enum AppointmentViewType {
  case Today
  case Upcoming
  case Wellcom
}
class HomeContainer: UIView,UICollectionViewDelegate,UICollectionViewDataSource {

  
  var pageControl = CHIPageControlJaloro().then { pageControl in
    pageControl.currentPageTintColor = R.color.theamBlue()
    pageControl.tintColor = R.color.theamBlue()?.withAlphaComponent(0.2)
    pageControl.radius = 2
    pageControl.padding = 8
    pageControl.elementWidth = 24
    pageControl.elementHeight = 4
    pageControl.hidesForSinglePage = false
  }
  
  lazy var layout = PagingCollectionViewLayout().then { layout in
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    layout.itemSize = CGSize(width: 160, height: 184)
    layout.numberOfItemsPerPage = 2
  }
  
  lazy var blogClv:UICollectionView = {
    let view = UICollectionView(frame: .zero,collectionViewLayout: layout)
    view.showsHorizontalScrollIndicator = false
    view.backgroundColor = .white
    view.delegate = self
    view.dataSource = self
    view.decelerationRate = .fast
    return view
  }()
  
  
  var blogDatas:[BlogModel] = [] {
    didSet {
      blogClv.reloadData()
      pageControl.numberOfPages = blogDatas.count / 2
    }
  }
  
  var money:String = "" {
    didSet {
      amountLabel.text = money
    }
  }
  
  var userModel:UserModel! {
    didSet {
      let level = userModel.new_recharge_card_level.int ?? 0
      
      if level == 0 || level == 1 { // basesic
        walletLevelLabel.text = "Basic Tier"
      }
      
      if level == 2 { // silver=
        walletLevelLabel.text = "Silver Tier"
      }
      
      if level == 3 { // gold=
        walletLevelLabel.text = "Gold Tier"
      }
      
      if level == 4 { // platinum
        walletLevelLabel.text = "Platinum Tier"
      }
      
      pointsLabel.text = userModel.points
    }
  }

  @IBOutlet weak var blogContentView: UIView!
  @IBOutlet weak var appointmentInfoHCons: NSLayoutConstraint!
  @IBOutlet weak var appointmentInfoView: UIView!
  @IBOutlet weak var walletLevelLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var pointsLabel: UILabel!
  @IBOutlet weak var kkContentView: UIView!
  private var selectBlogId:String = ""
  
  var updateContentHeight:((CGFloat)->())?
  
  let kingkongView = HomeKingKongView()
  var wellcomeView = HomeWellcomeView()
  var bookedView = HomeBookedServiceView()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.blogClv.register(nibWithCellClass: MadamPartumNewsItemCell.self)
    self.blogClv.dataSource = self
    self.blogClv.delegate = self
    blogClv.showsHorizontalScrollIndicator = false
    blogClv.backgroundColor = R.color.theamYellow()
    blogClv.decelerationRate = .fast
    
    blogContentView.addSubview(blogClv)
    blogContentView.addSubview(pageControl)
    
    kkContentView.addSubview(kingkongView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    blogClv.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.height.equalTo(184)
      make.top.equalToSuperview().offset(72)
    }
    pageControl.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalToSuperview().inset(16)
      make.height.equalTo(4)
    }
    kingkongView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return blogDatas.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withClass: MadamPartumNewsItemCell.self, for: indexPath)
    if blogDatas.count > 0 {
      cell.model = blogDatas[indexPath.row]
    }
    cell.shareHandler = { model in
      guard let url = URL(string: "\(APIHost().URL_BLOG_SHARE)\(model.id ?? "")"),let title = model.title else {
        return
      }
      ShareTool.shareBlog(title, url.absoluteString)

    }
    cell.contentView.backgroundColor = R.color.theamYellow()
    cell.bookmarkHandler = { [weak self] model in
      self?.selectBlogId = model.id!
      if model.has_booked { // 取消
        self?.deleteBlogFromBoard()
      }else {
        self?.checkHasDefaultBoards()
      }

    }
    cell.addImageViewShadow()
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let model = blogDatas[indexPath.item]
    let vc = BlogDetailViewController(blogId: model.id ?? "", hasBook: model.has_booked)
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.x == 0 {
      pageControl.set(progress: 0, animated: true)
    }else {
      let page = floor((scrollView.contentSize.width / scrollView.contentOffset.x))
      pageControl.set(progress: page.int - 1, animated: true)
    }
  }
  
  
  func checkHasDefaultBoards() {
    Toast.showLoading()
    let params = SOAPParams(action: .Blog, path: API.checkHasDefaultBoards)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      self.getBoardsForAddBlog()
    } errorHandler: { e in
      self.getBoardsForAddBlog()
    }

  }
  
  func getBoardsForAddBlog() {
    let params = SOAPParams(action: .Blog, path: API.getBoardsForAddBlog)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      guard let boards = DecodeManager.decodeByCodable([BlogBoardModel].self, from: data) else {
        return
      }
      let saveBoardView = BlogSaveToBoardSheetView.loadViewFromNib()
      saveBoardView.boards = boards
      let size = CGSize(width: kScreenWidth, height: saveBoardView.viewHeight)
      EntryKit.display(view: saveBoardView,
                       size: size,
                       style: .sheet,
                       backgroundColor: UIColor.black.withAlphaComponent(0.8),
                       touchDismiss: true)
      
      saveBoardView.createBoardHandler = {
        EntryKit.dismiss {
          let size = CGSize(width: kScreenWidth, height: 295 + kBottomsafeAreaMargin)
          let createBoardView = BlogCreateBoardSheetView()
          EntryKit.display(view: createBoardView,
                           size: size,
                           style: .sheet,
                           backgroundColor: UIColor.black.withAlphaComponent(0.8),
                           touchDismiss: true)
          createBoardView.contentView.addBoardHandler = {  text in
            self.saveBoard(text)
          }
        }
      }
      
      saveBoardView.selectBoardHandler = { model in
        self.saveBlogToBoard(boardId: model.id!)
      }
      
    } errorHandler: { error in
      
    }

  }
  
  func saveBoard(_ name:String) {
    let params = SOAPParams(action: .Blog, path: API.saveBoard)
    let data = SOAPDictionary()
    data.set(key: "id", value: 0)
    data.set(key: "name", value: name)
    data.set(key: "client_id", value: Defaults.shared.get(for: .clientId) ?? "")
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
      EntryKit.dismiss {
        self.getBoardsForAddBlog()
      }
    } errorHandler: { error in
      
    }
  }
  
  func saveBlogToBoard(boardId:String) {
    let params = SOAPParams(action: .Blog, path: API.saveBlogIntoBoard)
    let data = SOAPDictionary()
    data.set(key: "blog_id", value: selectBlogId)
    data.set(key: "board_id", value: boardId)
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
      // 修改cell状态
      self.updateCellBookmarkStatus(true)
      EntryKit.dismiss {
        Toast.showSuccess(withStatus: "Add Successful")
      }
      
    } errorHandler: { error in
      
    }
  }
  
  func deleteBlogFromBoard() {
    BlogBookmarkRemoveSheetView.show {
      Toast.showLoading()
      let params = SOAPParams(action: .Blog, path: API.deleteBlogFromBoard)
      params.set(key: "blogId", value: self.selectBlogId)
      NetworkManager().request(params: params) { data in
        Toast.dismiss()
        self.updateCellBookmarkStatus(false)
      } errorHandler: { e in
        
      }
    }
  }
  
  func updateCellBookmarkStatus(_ hasBook:Bool) {
    guard let index = self.blogDatas.firstIndex(where: { $0.id == self.selectBlogId }) else {
      return
    }
    self.blogDatas[index].has_booked = hasBook
    let indexPath = IndexPath(item: index, section: 0)
    self.blogClv.reloadItems(at: [indexPath])
  }

 
  
  @IBAction func infoAction(_ sender: Any) {
    let vc = TierPrivilegesController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
  }
  @IBAction func walletAction(_ sender: Any) {
    let vc = MyWalletController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
  }
  @IBAction func bookAppointmentAction(_ sender: Any) {
    let params = SOAPParams(action: .Client, path: .getClientCancelCount)
    params.set(key: "clientId", value: Defaults.shared.get(for: .clientId) ?? "")
    
    Toast.showLoading()
    NetworkManager().request(params: params) { data in
      Toast.dismiss()
      let count = JSON.init(from: data)?["cancel_count"].rawString()?.int ?? 0
      if count > 3 {
        AlertView.show(message: "If you delay cancelling more than 3 times, your in app reservation permission will be suspended.")
      }else {
        SelectTypeOfServiceSheetView.show()
       
      }
     
    } errorHandler: { e in
      Toast.dismiss()
    }
  }
  @IBAction func viewBlogAction(_ sender: Any) {
    let vc = BlogViewController()
    UIViewController.getTopVc()?.navigationController?.pushViewController(vc, completion: nil)
  }
  
 
  func updateAppointmentViewData(viewType:AppointmentViewType,today:[BookingTodayModel] = [],upcoming:[BookingUpComingModel] = []) {
    var totalH:CGFloat = 570
    var appointmentH:CGFloat = 0
    appointmentInfoView.removeSubviews()
    
    func addWellcomeView() {
      appointmentH = 74
      appointmentInfoView.addSubview(wellcomeView)
      wellcomeView.snp.makeConstraints { make in
        make.top.left.right.equalToSuperview()
        make.height.equalTo(appointmentH)
      }
    }
    if viewType == .Wellcom {
      addWellcomeView()
    }
    if viewType == .Today || viewType == .Upcoming{
      
      if viewType == .Today && today.count == 0 {
        addWellcomeView()
        return
      }
      if viewType == .Upcoming && upcoming.count == 0 {
        addWellcomeView()
        return
      }
      
      appointmentInfoView.addSubview(bookedView)
      bookedView.updateAppointmentViewData(viewType: viewType, today: today, upcoming: upcoming)
      appointmentH = bookedView.contentH
      bookedView.snp.makeConstraints { make in
        make.top.left.right.equalToSuperview()
        make.height.equalTo(appointmentH)
      }
    }

    appointmentInfoHCons.constant = appointmentH
    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
      self.setNeedsUpdateConstraints()
      self.layoutIfNeeded()
    } completion: { flag in
      
    }
    totalH += appointmentH
    updateContentHeight?(totalH)
  }
}
