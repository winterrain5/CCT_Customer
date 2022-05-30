//
//  BlogDetailView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/7.
//

import UIKit
import WebKit
import AVKit
class BlogDetailContainer: UIView,WKNavigationDelegate{
  @IBOutlet weak var blogImageView: UIImageView!
  @IBOutlet weak var blogTitleLabel: UILabel!
  @IBOutlet weak var blogAutherLabel: UILabel!
  @IBOutlet weak var blogDateLabel: UILabel!
  @IBOutlet weak var tagView: TTGTextTagCollectionView!
  @IBOutlet weak var bookmarkButton: UIButton!
  @IBOutlet weak var shareButton: UIButton!

  @IBOutlet weak var videoContentView: UIView!
  @IBOutlet weak var videoButton: UIButton!
  @IBOutlet weak var webView: WKWebView!
  @IBOutlet weak var webViewHCons: NSLayoutConstraint!
  var setContentCompleteHandler:((CGFloat)->())?
  let vc = AVPlayerViewController()
  lazy var createBoardView = BlogCreateBoardSheetView()
  
  var model:BlogDetailModel! {
    didSet {
      setup(content: model.content ?? "")
      
      blogImageView.yy_setImage(with: model.thumbnail_img?.asURL, options: .setImageWithFadeAnimation)
      blogTitleLabel.text = model.title
      blogAutherLabel.text = "by \(model.location_name ?? "")"
      bookmarkButton.isSelected = model.has_booked ?? false
      if let changeTime = model.change_time {
        blogDateLabel.text = changeTime.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM")
      }else {
        blogDateLabel.text = model.create_time?.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM")
      }
      
      self.tagView.removeAllTags()
      model.filters?.forEach({ [weak self] filter in
        guard let `self` = self else { return }
        self.addTags(filter.key_word ?? "")
      })
      self.tagView.reload()
      
      if let url = model.video_url,!url.isEmpty {
        videoContentView.isHidden = false
        let player = AVPlayer(url: URL(string: url)!)
        vc.player = player
        videoContentView.addSubview(vc.view)
        vc.view.frame = videoContentView.bounds
      }else {
        videoContentView.isHidden = true
      }
    }
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.showSkeleton()
    self.webView.navigationDelegate = self
    self.webView.scrollView.isScrollEnabled = false
    self.webView.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
    
    self.bookmarkButton.imageForNormal = R.image.blog_item_unbookmark()
      self.bookmarkButton.imageForSelected = R.image.blog_item_bookmark()
  }
  
  private func setup(content:String){
    
    let content = "<html><head><meta name= \"viewport\" content= \"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0\"></head><body>" + content + "</body></html>"
    self.webView.loadHTMLString(content, baseURL: nil)
    
  }
  
  func addTags(_ text:String) {
    let content = TTGTextTagStringContent(text: text, textFont: UIFont(name:.AvenirNextRegular,size:12), textColor: UIColor(hexString: "333333"))
    let style = TTGTextTagStyle()
    style.backgroundColor = UIColor(hexString: "#FAF3EB")!
    style.cornerRadius = 13
    style.exactHeight = 26
    style.minWidth = 60
    style.extraSpace = CGSize(width: 20, height: 0)
    style.borderWidth = 0
    style.shadowColor = .clear
    let tag = TTGTextTag(content: content, style: style)
    tagView.addTag(tag)
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
      let height = result as? CGFloat ?? 0
      self.webViewHCons.constant = height
      self.setContentCompleteHandler?(height + 368 + 220)
      self.setNeedsLayout()
      self.layoutIfNeeded()
    }
    self.hideSkeleton()
  }
  
  @IBAction func shareButtonAction(_ sender: Any) {
    guard let url = URL(string: "\(APIHost().URL_BLOG_SHARE)\(model.id ?? "")"),let title = model.title else {
      return
    }
    ShareTool.shareBlog(title, url.absoluteString)
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
          self.createBoardView.showView(from: self)
          self.createBoardView.contentView.addBoardHandler = {  text in
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
      
      self.createBoardView.dismiss()
      self.getBoardsForAddBlog()
      
    } errorHandler: { error in
      
    }
  }
  
  func saveBlogToBoard(boardId:String) {
    let params = SOAPParams(action: .Blog, path: API.saveBlogIntoBoard)
    let data = SOAPDictionary()
    data.set(key: "blog_id", value: self.model.id ?? "")
    data.set(key: "board_id", value: boardId)
    params.set(key: "data", value: data.result,type: .map(1))
    NetworkManager().request(params: params) { data in
      self.bookmarkButton.isSelected = true
      self.model.has_booked = true
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
      params.set(key: "blogId", value: self.model.id ?? "")
      NetworkManager().request(params: params) { data in
        Toast.dismiss()
        self.bookmarkButton.isSelected = false
        self.model.has_booked = false
      } errorHandler: { e in
        
      }
    }
  }
  @IBAction func bookMarkAction(_ sender: UIButton) {
    if sender.isSelected {
      deleteBlogFromBoard()
    }else {
      checkHasDefaultBoards()
    }
  }
  @IBAction func videoPlayAction(_ sender: Any) {
    
  }
}
