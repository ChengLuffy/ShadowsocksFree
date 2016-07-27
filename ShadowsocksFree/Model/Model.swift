//
//  Model.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/5.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit
import RealmSwift

class Model: Object {

    dynamic var name: String?
    dynamic var adress: String? {
        didSet {
            if adress!.containsString(":") {
                name = adress!.componentsSeparatedByString(":")[1].componentsSeparatedByString(".")[0].uppercaseString
            }
        }
    }
    dynamic var port: String?
    dynamic var passWord: String?
    dynamic var encryption: String?
    dynamic var stutas: String?
    dynamic var isNet: Bool = true
    
    /**
     realm 设置主键
     
     - returns: 主键
     */
    override class func primaryKey() -> String? {
        return "adress"
    }
    
}

let realm = try! Realm()
