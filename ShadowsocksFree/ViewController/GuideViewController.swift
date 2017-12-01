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
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "Guide1")
        return imageView
    }()
    
    private var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        (UIApplication.shared.delegate as! AppDelegate).window?.backgroundColor = UIColor.white
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
        
        
        if #available(iOS 11.0, *) {
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
            let imageViewVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: views)
            view.addConstraints(imageViewVC)
        }
        
        
        view.addConstraints(imageViewHC)
        
        
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
            window?.backgroundColor = UIColor.init(hexString: "#90C1F9")
            window?.rootViewController = nav
        } else {
            imageView.image = UIImage.init(named: "Guide\(page)")
        }
    }

}
