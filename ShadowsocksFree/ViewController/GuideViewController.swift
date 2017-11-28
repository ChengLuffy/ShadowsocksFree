//
//  GuideViewController.swift
//  ShadowsocksFree
//
//  Created by 成殿 on 2017/11/28.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Guide1")
        return imageView
    }()
    
    private var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.addSubview(imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["imageView": imageView]
        
        let imageViewHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views)
        let imageViewVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: views)
        
        view.addConstraints(imageViewHC)
        view.addConstraints(imageViewVC)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        page += 1
        if page > 4 {
            UserDefaults.standard.set(true, forKey: "hasOpened")
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let nav = storyboard.instantiateViewController(withIdentifier: "nav") as! UINavigationController
            window?.rootViewController = nav
        } else {
            imageView.image = UIImage.init(named: "Guide\(page)")
        }
    }

}
