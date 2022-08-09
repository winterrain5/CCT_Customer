//
//  Constants.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/31.
//

import Foundation
import UIKit
import RxSwift
import RxSwiftExt
import RxCocoa
import RxGesture
import RxRelay


/// 导航栏高度
let kNavBarHeight: CGFloat = UIDevice.navigationFullHeight()
/// tab栏高度
let kTabBarHeight: CGFloat = UIDevice.tabBarFullHeight()
/// 底部安全区域
let kBottomsafeAreaMargin: CGFloat = UIDevice.safeDistanceBottom()
/// 顶部安全区域
let kTopsafeAreaMargin: CGFloat = UIDevice.safeDistanceTop()
/// 状态栏高度
let kStatusBarHeight: CGFloat = UIDevice.statusBarHeight()
/// 屏幕高度
let kScreenHeight:CGFloat = UIScreen.main.bounds.size.height
/// 屏幕宽度
let kScreenWidth:CGFloat = UIScreen.main.bounds.size.width


let kPageSize:Int = 20

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



extension UIDevice {
    
    /// 顶部安全区高度
    static func safeDistanceTop() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.top
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.top
        }
        return 0;
    }
    
    /// 底部安全区高度
    static func safeDistanceBottom() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
        return 0;
    }
    
    /// 顶部状态栏高度（包括安全区）
    static func statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let statusBarManager = windowScene.statusBarManager else { return 0 }
            statusBarHeight = statusBarManager.statusBarFrame.height
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
    
    /// 导航栏高度
    static func navigationBarHeight() -> CGFloat {
        return 44.0
    }
    
    /// 状态栏+导航栏的高度
    static func navigationFullHeight() -> CGFloat {
        return UIDevice.statusBarHeight() + UIDevice.navigationBarHeight()
    }
    
    /// 底部导航栏高度
    static func tabBarHeight() -> CGFloat {
        return 49.0
    }
    
    /// 底部导航栏高度（包括安全区）
    static func tabBarFullHeight() -> CGFloat {
        return UIDevice.tabBarHeight() + UIDevice.safeDistanceBottom()
    }
}


