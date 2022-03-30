//
//  Int_Extension.swift
//  CCTIOS
//
//  Created by Derrick on 2022/1/4.
//

import Foundation
/// 时间戳格式
enum DateFormater:String {
    
    case second = "yyyy-MM-dd HH:mm:ss"
    case minute = "yyyy-MM-dd HH:mm"
    case hour = "yyyy-MM-dd HH"
    case day = "yyyy-MM-dd"
    case month = "yyyy-MM"
    case year = "yyyy"
}

extension Int {
    func dateString(_ dateFormat:DateFormater = .minute) -> String {
        let date:NSDate = NSDate.init(timeIntervalSince1970: self.double)
        let formatter = DateFormatter.init()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = dateFormat.rawValue
        return formatter.string(from: date as Date)
    }
    
}
