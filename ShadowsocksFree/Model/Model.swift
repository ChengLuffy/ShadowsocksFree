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

    @objc dynamic var name: String?
    @objc dynamic var adress: String? {
        didSet {
            name = adress!.uppercased()
        }
    }
    @objc dynamic var port: String?
    @objc dynamic var passWord: String?
    @objc dynamic var encryption: String?
    @objc dynamic var stutas: String?
    @objc dynamic var isNet: Bool = true
    @objc dynamic var server: String?
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
