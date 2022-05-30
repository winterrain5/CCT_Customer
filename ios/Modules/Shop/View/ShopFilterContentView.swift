//
//  ShopFilterView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/2/8.
//

import UIKit

class ShopFilterContentView: UIView,TTGTextTagCollectionViewDelegate,RangeSliderViewDelegate {

  @IBOutlet weak var filterTagView: TTGTextTagCollectionView!
  
  @IBOutlet weak var categoryTagView: TTGTextTagCollectionView!
  
  @IBOutlet weak var categoryTagViewHCons: NSLayoutConstraint!
  
  @IBOutlet weak var rangSlider: RangeSliderView!
  
  @IBOutlet weak var priceTagView: TTGTextTagCollectionView!
  @IBOutlet weak var minValueLabel: UILabel!
  @IBOutlet weak var maxValueLabel: UILabel!
  
  var filterSelectedIndex:UInt = 0
  var priceSelectedIndex:UInt = 0
  
  var prices:[(String,String)] = [("0","20"),("20","50"),("50","100"),("100","200"),("200","300"),("300","10000")]
  
  var updateHeightHandler:((CGFloat)->())?
  
  var result = CCTShopFilterRequestModel() {
    didSet {
      if result.orderBy == "DESC" {
        filterTagView.updateTag(at: 0, selected: true)
        filterSelectedIndex = 0
      }
      
      if result.orderBy == "ASC" {
        filterTagView.updateTag(at: 1, selected: true)
        filterSelectedIndex = 1
      }
    
      let range = (result.price_low,result.price_high)
      if let index = prices.firstIndex(where: { ($0.0 == range.0) && ($0.1 == range.1) })?.uInt {
        priceTagView.updateTag(at: index, selected: true)
        priceSelectedIndex = index
      }
      
    }
  }
  var productCategorys:[ProductCategoryModel] = []
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    addTags("$ High to Low", filterTagView,115)
    addTags("$ Low to High", filterTagView,115)
    filterTagView.delegate = self
    
    categoryTagView.delegate = self
    
    prices.map({ "$" + $0.0 + " - " + $0.1 }).forEach { [weak self] price in
      guard let `self` = self else { return }
      let width = (kScreenWidth - 48 - 22) / 3
      self.addTags(price, self.priceTagView,width)
    }
    priceTagView.delegate = self
    
    rangSlider.delegate = self
    rangSlider.maximumValue = self.prices.last?.1.double() ?? 0
    rangSlider.minimumValue = 0
    rangSlider.upperValue = self.prices.last?.1.double() ?? 0
    rangSlider.lowerValue = 0
    rangSlider.cornerRadius = 12
    rangSlider.clipsToBounds = true
    maxValueLabel.text = "$" + (self.prices.last?.1 ?? "")
    
    getCategory()
    
  }
  
  func getCategory() {
    let params = SOAPParams(action: .Category, path: .getTCategories)
    params.set(key: "companyId", value: Defaults.shared.get(for: .companyId) ?? "97")
    params.set(key: "productType", value: "TCM_INVENTORY_PRODUCT_NAME")
    params.set(key: "showProCount", value: "false")
    
    NetworkManager().request(params: params) { data in
      if let models = DecodeManager.decodeArrayByHandJSON(ProductCategoryModel.self, from: data) {
        self.productCategorys = models
        models.forEach { model in
          self.addTags(model.name, self.categoryTagView)
        }
        let categoryHeight = self.categoryTagView.contentSize.height
        self.categoryTagViewHCons.constant = categoryHeight + 6
        self.updateHeightHandler?(categoryHeight + 6 + 430)
        
        self.result.category.forEach { e in
          let index = models.firstIndex(where: { $0.id == e.id })?.uInt ?? 0
          self.categoryTagView.updateTag(at: index, selected: true)
          
        }
      }
    } errorHandler: { e in
      
    }

  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
  }
  
  func addTags(_ text:String,_ tagView:TTGTextTagCollectionView,_ exactWidth:CGFloat = 0) {
    let content = TTGTextTagStringContent(text: text, textFont: UIFont(name:.AvenirNextRegular,size:14), textColor: UIColor(hexString: "#828282")!)
    let style = TTGTextTagStyle()
    style.backgroundColor = .white
    style.cornerRadius = 13
    style.exactHeight = 36
    style.exactWidth = exactWidth
    style.minWidth = 60
    style.extraSpace = CGSize(width: 24, height: 0)
    style.borderWidth = 1
    style.borderColor = UIColor(hexString: "#828282")!
    style.shadowColor = .clear
    
    let selectContent = TTGTextTagStringContent(text: text, textFont: UIFont(name: .AvenirNextDemiBold, size:14), textColor: .white)
    let selectedStyle = style.copy() as! TTGTextTagStyle
    selectedStyle.backgroundColor = R.color.theamBlue()!
    selectedStyle.borderWidth = 0
    
    let tag = TTGTextTag(content: content, style: style, selectedContent: selectContent, selectedStyle: selectedStyle)
    tagView.horizontalSpacing = 8
    tagView.verticalSpacing = 8
    tagView.contentInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    tagView.addTag(tag)
  
  }
  
  
  func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
    if textTagCollectionView == filterTagView {
      filterTagView.updateTag(at: filterSelectedIndex, selected: false)
      filterTagView.updateTag(at: index, selected: true)
      filterSelectedIndex = index
      result.orderBy = index == 0 ? "DESC" : "ASC"
      
    }
    
    if textTagCollectionView == categoryTagView {
      if tag.selected {
        result.category.append(self.productCategorys[Int(index)])
      }else {
        
        result.category.removeAll(where: { $0.id == self.productCategorys[Int(index)].id })
      }
    }
   
    if textTagCollectionView == priceTagView {
      priceTagView.updateTag(at: priceSelectedIndex, selected: false)
      priceTagView.updateTag(at: index, selected: true)
      priceSelectedIndex = index
      
      minValueLabel.text = "$" + prices[Int(index)].0
      maxValueLabel.text = "$" + prices[Int(index)].1
      
      let min = String(format: "%.f", prices[Int(index)].0.double() ?? 0)
      let max = String(format: "%.f", prices[Int(index)].1.double() ?? 0)
      
      rangSlider.maximumValue = max.double() ?? 0
      rangSlider.minimumValue = min.double() ?? 0
      rangSlider.upperValue = max.double() ?? 0
      rangSlider.lowerValue = min.double() ?? 0
      
      result.price_low = min
      result.price_high = max
      result.range = "$\(min) - \(max)"
    }
    
  }
  
  func sliderValueChanged(slider: RangeSlider?) {
    let min = String(format: "%.f", slider?.lowerValue ?? 0)
    let max = String(format: "%.f", slider?.upperValue ?? 0)
    minValueLabel.text = "$" + min
    maxValueLabel.text = "$" + max
    
    result.price_low = min
    result.price_high = max
    result.range = "$\(min) - \(max)"
  }
  
}


