//
//  EmptyDataType.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/31.
//

import Foundation
public enum EmptyStatus {
    enum Message:String {
        case NoData = "No Data"
        case Service = "oops! something wrong..."
        case Network = "oops! network is down"
    }
    
    enum Image:String {
        case NoData = "empty_nodata_placeholder"
        case Service = "empty_service_error"
        case Network = "empty_network_error"
    }
}


public enum EmptyDataType:Equatable {
    case TimeOut// 超时
    case Network(code:Int,message:String)// 网络出错
    case NoData// 没有数据
    case DecodeError
    case Service(code:Int,message:String)// 服务器接口出错
    case NotLogin
    case Success
    
    static func emptyImage(for type:EmptyDataType, noDataImage:String) -> UIImage {
      UIImage(color: .white, size: .zero)
//        var imageName:String = EmptyStatus.Image.NoData.rawValue
//        switch type {
//        case .NoData:
//            imageName = noDataImage.isEmpty ? imageName : noDataImage
//        case .Network:
//            imageName = EmptyStatus.Image.Network.rawValue
//        case .TimeOut:
//            imageName = EmptyStatus.Image.Network.rawValue
//        case .Service:
//            imageName = EmptyStatus.Image.Service.rawValue
//        default:
//            imageName = EmptyStatus.Image.NoData.rawValue
//        }
//        return UIImage(named: imageName) ?? UIImage(color: .white, size: .zero)
    }
    
    static func emptyString(for type:EmptyDataType,noDataString: String) -> NSAttributedString {
        var text:String = EmptyStatus.Message.NoData.rawValue
        switch type {
        case .NoData:
            text = noDataString.isEmpty ? text : noDataString
        case .Network:
            text = EmptyStatus.Message.Network.rawValue
        case .TimeOut:
            text = EmptyStatus.Message.Network.rawValue
        case .Service:
            text = EmptyStatus.Message.Service.rawValue
        default:
            text = "No Data"
        }
        let attributes:[NSAttributedString.Key:AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 14),NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.gray]
        
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
    static func buttonImage(for type:EmptyDataType) -> UIImage {
      UIImage(color: .white, size: .zero)
//        var imageName:String = ""
//        switch type {
//        case .NotLogin:
//            imageName = "empty_login_button"
//        case .Service,.TimeOut,.Network:
//            imageName = "empty_refresh_button"
//        default:
//            return UIImage(color: .clear, size: .zero)
//        }
//        return UIImage.init(named: imageName) ?? UIImage(color: .white, size: .zero)
    }
}

