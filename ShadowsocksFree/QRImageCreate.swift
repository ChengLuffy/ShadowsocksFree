//
//  QRImageCreate.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/7.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

extension UIImage {

    class func createQRImage(info info: String, scale: CGFloat) -> UIImage {
        let filter = CIFilter.init(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = info.dataUsingEncoding(NSUTF8StringEncoding)
        filter?.setValue(data, forKey: "inputMessage")
        
        let outputImage = filter?.outputImage
        
        let ratio: CGFloat = scale / CGRectGetWidth((outputImage?.extent)!)
        let transform = CGAffineTransformMakeScale(ratio, ratio)
        let transformImage = outputImage?.imageByApplyingTransform(transform)
        
        let context = CIContext.init(options: nil)
        let imageRef = context.createCGImage(transformImage!, fromRect: (transformImage?.extent)!)
        
        return UIImage.init(CGImage: imageRef)
    }
    
}

extension NSString {
    func base64EncodedString() -> NSString {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return (data?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))!
    }
}
