//
//  Model.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/5.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class Model: NSObject {

    var name: String?
    var adress: String? {
        didSet {
          name = adress!.componentsSeparatedByString(":")[1].substringToIndex(adress!.startIndex.advancedBy(2)).uppercaseString
        }
    }
    var port: String?
    var passWord: String?
    var encryption: String?
    var stutas: String?
    
}
