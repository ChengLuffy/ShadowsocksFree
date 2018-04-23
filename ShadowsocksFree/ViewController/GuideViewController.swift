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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let msg = """
        1.此软件内节点可能在下一刻就无法使用；
        2.此软件可能在下一刻就无法使用；
        3.此软件节点很慢，作者无力也无心优化维护；
        4.此软件仅供您应急使用，所有的节点每六小时更换密码，如果您发现不能用了，请及时打开软件重新链接
        5.你值得拥有更好的网络，更好的一切！
        """
        let alertC = UIAlertController(title: "声明", message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "不同意", style: .destructive) { (action) in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            UIApplication.shared.perform(Selector(("terminateWithSuccess")))
        }
        let okAction = UIAlertAction(title: "同意", style: .default) { (_) in
        }
        alertC.addAction(cancelAction)
        alertC.addAction(okAction)
        present(alertC, animated: true, completion: nil)
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
//            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            let metrics = ["topAnchor": view.safeAreaInsets.top, "bottomAnchor": view.safeAreaInsets.bottom] as [String : Any]
            let imageViewVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-topAnchor-[imageView]-bottomAnchor-|", options: [], metrics: metrics, views: views)
            view.addConstraints(imageViewVC)
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
