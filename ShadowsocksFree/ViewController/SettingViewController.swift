//
//  SettingViewController.swift
//  ShadowsocksFree
//
//  Created by 成殿 on 2017/11/28.
//  Copyright © 2017年 成璐飞. All rights reserved.
//

import UIKit
import StoreKit

class SettingViewController: UIViewController {
    
    private lazy var buyBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("buyTee", comment: ""), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.backgroundColor = UIColor.blue
        button.titleLabel?.textColor = UIColor.white
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blue.cgColor
        button.addTarget(self, action: #selector(SettingViewController.buyBtnAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "关闭"), for: .normal)
        button.addTarget(self, action: #selector(SettingViewController.closeBtnAction), for: .touchUpInside)
        return button
    }()
    
    private var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        // #2179FD
        label.textColor = UIColor.init(hexString: "#2179FD")
        label.text =
        """
        """
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        view.addSubview(buyBtn)
        view.addSubview(closeBtn)
        view.addSubview(infoLabel)
        SKPaymentQueue.default().add(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        buyBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["buyBtn": buyBtn, "closeBtn": closeBtn, "infoLabel": infoLabel] as [String : Any]
        
        let buyBtnHC = NSLayoutConstraint.constraints(withVisualFormat: "H:[buyBtn(200)]", options: [], metrics: nil, views: views)
        let buyBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-150-[buyBtn(40)]", options: [], metrics: nil, views: views)
        let buyBtnHCenter = NSLayoutConstraint.init(item: buyBtn, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let closeBtnHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|-25-[closeBtn]", options: [], metrics: nil, views: views)
        var closeBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-35-[closeBtn]", options: [], metrics: nil, views: views)
        
        if #available(iOS 11.0, *) {
            let metrics = ["topAnchor": view.safeAreaInsets.top + 20 , "bottomAnchor": view.safeAreaInsets.bottom] as [String : Any]
            closeBtnVC = NSLayoutConstraint.constraints(withVisualFormat: "V:|-topAnchor-[closeBtn]", options: [], metrics: metrics, views: views)
        }
        
        
        let infoLabelVC = NSLayoutConstraint.constraints(withVisualFormat: "V:[buyBtn]-25-[infoLabel]", options: [], metrics: nil, views: views)
        let infoLabelHC = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=10)-[infoLabel]-(>=10)-|", options: [], metrics: nil, views: views)
        let infoLabelHCenter = NSLayoutConstraint.init(item: infoLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        
        view.addConstraints(infoLabelVC)
        view.addConstraints(infoLabelHC)
        view.addConstraint(infoLabelHCenter)
        
        view.addConstraints(closeBtnHC)
        view.addConstraints(closeBtnVC)
        
        view.addConstraint(buyBtnHCenter)
        view.addConstraints(buyBtnHC)
        view.addConstraints(buyBtnVC)
        
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func buyBtnAction() {
        view.isUserInteractionEnabled = false
        closeBtn.isEnabled = false
        buyBtn.isEnabled = false
        buyBtn.setTitle(NSLocalizedString("processing", comment: ""), for: .normal)
        let productionID = ["tech.chengluffy.tee"]
        let teeRequest = SKProductsRequest.init(productIdentifiers: Set(productionID))
        teeRequest.delegate = self
        teeRequest.start()
    }
    
    @objc func closeBtnAction() {
        dismiss(animated: true, completion: nil)
    }
    
    private func enableUserInteraction() {
        closeBtn.isEnabled = true
        buyBtn.isEnabled = true
        buyBtn.setTitle(NSLocalizedString("buyTee", comment: ""), for: .normal)
        view.isUserInteractionEnabled = true
    }
    
}

extension SettingViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let tee = response.products.first
        let payment = SKPayment(product: tee!)
        SKPaymentQueue.default().add(payment)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        AlertMSG.alert(title: "Error", msg: error.localizedDescription, actions: [cancelAction])
        enableUserInteraction()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("request finish")
    }
}

extension SettingViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let transaction = transactions.first
        if transaction?.transactionState == SKPaymentTransactionState.purchased {
            SKPaymentQueue.default().finishTransaction(transaction!)
            enableUserInteraction()
        } else if transaction?.transactionState == SKPaymentTransactionState.failed {
            SKPaymentQueue.default().finishTransaction(transaction!)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            AlertMSG.alert(title: "Error", msg: (transaction!.error?.localizedDescription)!, actions: [cancelAction])
            enableUserInteraction()
        } else if transaction?.transactionState == SKPaymentTransactionState.purchasing {
            print("商品添加到列表")
        } else if transaction?.transactionState == SKPaymentTransactionState.restored {
            print("已经购买过该商品")
        } else if transaction?.transactionState == SKPaymentTransactionState.deferred {
            print("延期")
        } else {
            print(transaction ?? "production nil")
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("finish")
    }
    
}
