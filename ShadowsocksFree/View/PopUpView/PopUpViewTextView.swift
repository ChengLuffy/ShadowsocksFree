//
//  PopUpViewTextView.swift
//  ShadowsocksFree
//
//  Created by 成璐飞 on 16/6/23.
//  Copyright © 2016年 成璐飞. All rights reserved.
//

import UIKit

class PopUpViewTextView: UIView {

    @IBOutlet var mainView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainView = NSBundle.mainBundle().loadNibNamed("PopUpViewTextView", owner: self, options: nil).first as! UIView
        mainView.frame = CGRect(x: 0, y: 0, width: 320, height: 200)
        mainView.center = self.center
        self.addSubview(mainView)
        
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 350, height: 50))
        label.text = "请输入配置信息"
        label.textAlignment = .Center
        label.textColor = UIColor(red: 29.0 / 255.0, green: 169.0 / 255.0, blue: 209.0 / 255.0, alpha: 1)
        label.center = CGPoint(x: self.center.x, y: 70)
        label.font = UIFont.boldSystemFontOfSize(30)
        self.addSubview(label)
        self.backgroundColor = UIColor.whiteColor()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.endEditing(true)
    }
}

extension PopUpViewTextView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let basicAnimation = CABasicAnimation.init(keyPath: "transform.scale.x")
        let progressLine = mainView.viewWithTag(textField.tag + 10)
        progressLine!.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        basicAnimation.duration = 0.3
        basicAnimation.repeatCount = 1
        basicAnimation.removedOnCompletion = false
        basicAnimation.fromValue = NSNumber.init(float: 1)
        basicAnimation.toValue = NSNumber.init(float: 280)
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn)
        progressLine!.layer.addAnimation(basicAnimation, forKey: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("TFTag", object: textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            let basicAnimation = CABasicAnimation.init(keyPath: "transform.scale.x")
            let progressLine = mainView.viewWithTag(textField.tag + 10)
            progressLine!.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            basicAnimation.duration = 0.3
            basicAnimation.repeatCount = 1
            basicAnimation.removedOnCompletion = false
            basicAnimation.fromValue = NSNumber.init(float: Float(280))
            basicAnimation.toValue = NSNumber.init(float: 1)
            basicAnimation.fillMode = kCAFillModeForwards
            basicAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn)
            progressLine!.layer.addAnimation(basicAnimation, forKey: nil)
        }
    }
    
}

