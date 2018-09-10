//
//  GetNetData.swift
//  ShadowsocksFree
//
//  Created by 成殿 on 2018/4/17.
//  Copyright © 2018年 成璐飞. All rights reserved.
//

import Foundation
import Alamofire
import Fuzi
import RealmSwift

class NetData {
    
    class func RefreshData(success: @escaping (_ isSuccess: Bool)->(),failure: @escaping (_ error: Error?)->()) {
        var URLStr: String = "https://us.ishadowx.net"
        let userDefaults = UserDefaults.init(suiteName: "group.tech.chengluffy.shadowsocksfree")
        
        if userDefaults?.value(forKey: "url") != nil && userDefaults?.string(forKey: "url") != "" {
            URLStr = userDefaults?.value(forKey: "url") as! String
        }
        
        
        Alamofire.request(URLStr).responseData { (respose) in
            
            if respose.result.error == nil {
                print(respose.data?.count ?? "nil")
                
                let html = NSString.init(data: respose.data!, encoding: String.Encoding.utf8.rawValue)
                do {
                    
                    try! realm.write({
                        realm.delete(realm.objects(Model.self).filter("server = 'ishadowsocks'"))
                    })
                    
                    let doc = try HTMLDocument(string: html! as String, encoding: String.Encoding.utf8)
                    let free = doc.xpath("//body")[0].children(tag: "div")[2].children(tag: "div")[1].children(tag: "div")[1].children(tag: "div")[0].children(tag: "div")
                    if free.count > 0 {
                        for node in free {
                            let model = Model()
                            
                            for (index, sub) in node.children(tag: "div")[0].children(tag: "div")[0].children(tag: "div")[0].children(tag: "h4").enumerated() {
                                
                                switch index {
                                case 0: model.address = (sub.stringValue.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                                case 1: model.port = sub.stringValue.components(separatedBy: ":").last!.trimmingCharacters(in: .whitespacesAndNewlines)
                                case 2: model.passWord = (sub.stringValue.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                                case 3: model.encryption = sub.stringValue.components(separatedBy: ":").last!.trimmingCharacters(in: .whitespacesAndNewlines)
                                default :
                                    break
                                }
                                model.isNet = true
                                model.server = "ishadowsocks"
                            }
                            
                            try! realm.write({
                                realm.add(model, update: true)
                            })
                            success(true)
                        }
                    } else {
                        print("nil")
                        failure(nil)
                    }
                    
                } catch let error  {
                    print(error)
                    failure(error)
                }
            } else {
                print(respose.result.error ?? "nil")
                failure(respose.result.error)
            }
        }
    }
    
    class func getSSQRStr(_ num: Int) -> String! {
        let model = realm.objects(Model.self).filter("isNet = true")[num]
        print(model.address!)
        let method: NSString = model.encryption! as NSString
        
        let passWord: NSString?
        if (model.passWord?.count)! > 5 {
            passWord = model.passWord as NSString?
        } else {
            passWord = ""
        }
        
        let adress: NSString = model.address! as NSString
        
        let port: NSString = model.port! as NSString
        let temp: NSString = NSString.init(format: "\(method.trimmingCharacters(in: .whitespacesAndNewlines)):\(passWord!.trimmingCharacters(in: .whitespacesAndNewlines))@\(adress.trimmingCharacters(in: .whitespacesAndNewlines)):\(port.trimmingCharacters(in: .whitespacesAndNewlines))" as NSString)
        let temp1 = temp.base64EncodedString()
        let retStr = "ss://" + (temp1 as String)
        
        return retStr.replacingOccurrences(of: "\r\n", with: "")
    }
}
