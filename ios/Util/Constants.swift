//
//  Constants.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/31.
//

import Foundation
/// 导航栏高度
let kNavBarHeight: CGFloat = iPhoneX() ? 92 : 64
/// tab栏高度
let kTabBarHeight: CGFloat = iPhoneX() ? 83 : 49
/// 底部安全区域
let kBottomsafeAreaMargin: CGFloat = iPhoneX() ? 34 : 0
/// 顶部安全区域
let kTopsafeAreaMargin: CGFloat = iPhoneX() ? 44 : 0
/// 状态栏高度
let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
/// 屏幕高度
let kScreenHeight:CGFloat = UIScreen.main.bounds.size.height
/// 屏幕宽度
let kScreenWidth:CGFloat = UIScreen.main.bounds.size.width


let kPageSize:Int = 18

/// 判断是否是iPhone
func iPhoneX() -> Bool {
    if #available(iOS 11, *) {
        guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
            return false
        }
        if  unwrapedWindow.safeAreaInsets.bottom > 0 {
            return true
        }
    }
    return false
}

