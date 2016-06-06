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
          name = adress!.componentsSeparatedByString(":")[1].substringToIndex(adress!.startIndex.advancedBy(2)).uppercaseString
        }
    }
    dynamic var port: String?
    dynamic var passWord: String?
    dynamic var encryption: String?
    dynamic var stutas: String?
    
}

public class realm {
    static let sharedInstance = try! Realm()
}
