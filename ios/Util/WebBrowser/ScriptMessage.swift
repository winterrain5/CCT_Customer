//
//  ScriptMessage.swift
//  OneOnline
//
//  Created by Derrick on 2020/4/3.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit

protocol WebViewMessageHandlerProtocol {
    func didReceiveScriptMessage(webView: WebView, message: ScriptMessage)
}



class ScriptMessage:Codable {
    var action: String = ""
    var time: Int = 0
    var messageId:String = ""
}
