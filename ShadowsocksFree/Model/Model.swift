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
            if adress!.contains(":") {
//                name = adress!.componentsSeparatedBy(":")[1].componentsSeparatedByString(".")[0].uppercased()
                name = adress!.components(separatedBy: ":")[1].uppercased()
            }
        }
    }
    dynamic var port: String?
    dynamic var passWord: String?
    dynamic var encryption: String?
    dynamic var stutas: String?
    dynamic var isNet: Bool = true
//    dynamic override var invalidated: Bool { return super.invalidated }
    
    /**
     realm 设置主键
     
     - returns: 主键
     */
    override class func primaryKey() -> String? {
        return "adress"
    }
    
}

let realm = try! Realm()
