//
//  UITableView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/14.
//

import Foundation

extension UITableView {
  /// 获取最大高度
  /// - Parameters:
  ///   - maxRowCount: 最大row的count
  ///   - maxSectionCount: 最大section的count，为0表示所有
  public func getMaxHeight(with maxRowCount: Int, maxSectionCount: Int = 0) -> CGFloat {
    var sectionCount = maxSectionCount
    if maxSectionCount >= numberOfSections || maxSectionCount <= 0 {
      sectionCount = numberOfSections
    }
    var maxHeight: CGFloat = tableHeaderView?.frame.size.height ?? 0;
    for sectionIndex in 0..<sectionCount {
      var rowCount = numberOfRows(inSection: sectionIndex)
      if (rowCount > maxRowCount) {
        rowCount = maxRowCount;
      }
      
      maxHeight += delegate?.tableView?(self, heightForHeaderInSection: sectionCount) ?? 0
      for rowIndex in 0..<rowCount {
        maxHeight += delegate?.tableView?(self, heightForRowAt: IndexPath(row: rowIndex, section: sectionIndex)) ?? 0
        
      }
    }
    return maxHeight;
  }
  /// 获取指定高度的tableView image
  /// - Parameter maxHeight: 最大高度
  public func generateTableViewImage(with maxHeight: CGFloat) -> UIImage? {
    var viewImage: UIImage?
    
    let savedContentOffset = contentOffset
    let savedFrame = frame
    
    let imageHeight = maxHeight > 0 ? maxHeight :contentSize.height
    var screensInTable = 0
    
    if (frame.size.height != 0) {
      screensInTable = Int(ceil(imageHeight / frame.size.height))
    }
    
    let sectionNum = numberOfSections
    
    //        autoreleasepool {
    let imageSize = CGSize(width: frame.size.width, height: maxHeight)
    UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
    
    frame = CGRect(x: 0, y: 0, width: contentSize.width, height: imageHeight)
    
    let oldBounds = layer.bounds
    
    
    if #available(iOS 15, *) {
      //iOS 15 系统截屏需要改变tableview 的bounds
      layer.bounds = CGRect(x: oldBounds.origin.x,
                            y: oldBounds.origin.y,
                            width: contentSize.width,
                            height: contentSize.height)
      
      //偏移量归零
      contentOffset = CGPoint.zero
      //frame变为contentSize
      frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
    }
    
    
    for i in 0..<screensInTable {
      let contentOffset = CGPoint(x: CGFloat(0), y: CGFloat(i) * frame.size.height)
      setContentOffset(contentOffset, animated: false)
      
      // 隐藏应该移出屏幕的sectionHeader
      if (style == .plain) {
        for i in 0..<sectionNum {
          let headerRect = rect(forSection: i)
          if (headerRect.origin.y < contentOffset.y) {
            setupHeaderView(with: i, false)
          }
        }
      }
      if let context = UIGraphicsGetCurrentContext() {
        layer.render(in: context)
      }
    }
    
    if #available(iOS 15, *) {
      layer.bounds = oldBounds
    }
    
    viewImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if (style == .plain) {
      for i in 0..<sectionNum {
        setupHeaderView(with: i, false)
      }
    }
    
    frame = savedFrame
    setContentOffset(savedContentOffset, animated: false)
    return viewImage
  }
  
  /// 设置HeaderView的显示隐藏
  /// - Parameters:
  ///   - section: header所在的section
  ///   - isHidden: 是否隐藏
  private func setupHeaderView(with section: Int, _ isHidden: Bool) {
    
    var headerView1 = headerView(forSection: section)
    headerView1 = delegate?.tableView?(self, viewForHeaderInSection: section) as? UITableViewHeaderFooterView
    headerView1?.isHidden = isHidden
  }
}
