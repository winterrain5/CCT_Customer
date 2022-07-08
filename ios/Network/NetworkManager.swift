//
//  NetworkManager.swift
//  CCTIOS
//
//  Created by Derrick on 2021/12/31.
//

import Foundation
import DKLogger

class NetworkManager:NSObject, XMLParserDelegate {

  private var session:URLSession!
  
  private var result:String = ""
  private var currentNodeName:String = ""
  
  var successHandler:(Data)->() = {_ in }
  var errorHandler:(APIError)->() = {_ in }
  var params:SOAPParams!
  
  override init() {
    super.init()
    session = URLSession(configuration: .default)
  }
  /// post请求
  /// - Parameters:
  ///   - action: 接口控制器
  ///   - path: 接口地址
  ///   - response: 返回体对应的key
  ///   - paramValues: 参数
  public func request(params:SOAPParams,
                      successHandler:@escaping (Data)->(),
                      errorHandler:@escaping (APIError)->()){
    self.successHandler = successHandler
    self.errorHandler = errorHandler
    self.params = params
    guard let url = getURL(action: params.action) else { return }
    
    let soapMsg:String = createSoapMessage(path:params.path, pams: params.result)
   
    
    let urlRequest: URLRequest = getURLRequest(url: url, soapMsg: soapMsg)
    var task:URLSessionTask!
    task = session.dataTask(with: urlRequest) { data, response, error in
      if error == nil,data != nil {
        let parser = XMLParser(data: data!)
        parser.delegate = self
        parser.parse()
      }else {
        let message = error?.localizedDescription ?? ""
        DispatchQueue.main.async {
          Toast.dismiss()
          self.errorHandler(APIError.networkError(error!))
          if self.params.isNeedToast {
            AlertView.show(message: message)
          }
        }
        task.cancel()
      }
    }
    
    task.resume()
  }
  
  private  func getURL(action:String) -> URL?{
    let urlStr = APIHost().URL_API_HOST + action  + URL_API_END_HOST;
    return URL(string: urlStr)
  }
  
  private func getURLRequest(url:Foundation.URL,soapMsg:String)->URLRequest{
    
    var request:URLRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 8)
    request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("urn:QueryControllerwsdl", forHTTPHeaderField: "SOAPAction")
    request.setValue("\(soapMsg.count)", forHTTPHeaderField: "Content-Length")
    request.httpMethod = "POST"
    request.httpBody = soapMsg.data(using: String.Encoding.utf8)
    
    return request
  }
  
  private  func createSoapMessage(path: String, pams: String) -> String {
    var message: String = String()
    message +=  "<v:Envelope xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:d=\"http://www.w3.org/2001/XMLSchema\" xmlns:c=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:v=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    message += "<v:Header/>"
    message += "<v:Body>"
    message += "<n0:\(path) id=\"o0\" c:root=\"1\" xmlns:n0=\"http://terra.systems/\">"
    message += "\(pams)"
    message += "</n0:\(path)>"
    message += "</v:Body>"
    message += "</v:Envelope>"
    return message
  }
}

extension NetworkManager {
  //获取节点及属性
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    result = ""
    currentNodeName = elementName
    
  }
  
  //获取节点的文本内容
  func parser(_ parser: XMLParser, foundCharacters string: String) {
  
    let str = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    result.append(str)
    
    
  }
  
  func parserDidEndDocument(_ parser: XMLParser) {
    if currentNodeName == "faultstring" {
      
      print("soapMsg:\(createSoapMessage(path:self.params.path, pams: self.params.result))")
    
      DispatchQueue.main.async {
#if DEBUG
        Toast.showError(withStatus: self.result)
#endif
        self.errorHandler(APIError.requestError(code: -1, message: self.result))
      }
   
      print("faultstring:\(result)")
  
    }
    
    if currentNodeName == "return" {
      if result != ""{
        
        let json = JSON(parseJSON: result)
        
        print("soapMsg:\(createSoapMessage(path:self.params.path, pams: self.params.result))")
        if let url = getURL(action: params.action) {
          print("url:\(url.absoluteString) path:\(params.path) \n response:\(json.dictionaryValue)")
        }
        
       
        DispatchQueue.main.async {
          guard let code = json["success"].int,let message = json["message"].string else {
            self.errorHandler(APIError.serviceError(.unableParse))
            return
          }
          
          if code != 1 {
            #if DEBUG
            if self.params.isNeedToast && !message.isEmpty{
              Toast.showError(withStatus: message)
            }
            #else
            if self.params.isNeedToast {
              AlertView.show(message: "The system is abnormal. Please try again later")
            }
            #endif
            self.errorHandler(APIError.requestError(code: code, message: message))
            return
          }
          
          guard let data = json["data"].rawString()?.data(using: .utf8) else {
            self.errorHandler(APIError.requestError(code: -1, message: "convert json['data'] to data failed"))
            return
          }
          self.successHandler(data)
        }
      }
    }
  }
}




