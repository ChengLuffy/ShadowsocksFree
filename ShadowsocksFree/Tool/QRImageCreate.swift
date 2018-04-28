//
//  QRImageCreate.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/7.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

extension UIImage {

    class func createQRImage(info: String, scale: CGFloat) -> UIImage {
        let filter = CIFilter.init(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = info.data(using: String.Encoding.utf8)
        filter?.setValue(data, forKey: "inputMessage")
        
        let outputImage = filter?.outputImage
        
        let ratio: CGFloat = scale / (outputImage?.extent)!.width
        let transform = CGAffineTransform(scaleX: ratio, y: ratio)
        let transformImage = outputImage?.transformed(by: transform)
        
        let context = CIContext.init(options: nil)
        let imageRef = context.createCGImage(transformImage!, from: (transformImage?.extent)!)
        
        return UIImage.init(cgImage: imageRef!)
    }
    
}

extension NSString {
    func base64EncodedString() -> NSString {
        let data = self.data(using: String.Encoding.utf8.rawValue)
        return (data?.base64EncodedString(options: .lineLength64Characters))! as NSString
    }
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self as String) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
