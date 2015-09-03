//
//  PurchaseViewCtrl.swift
//  oneCampusParent
//
//  Created by Cloud on 8/27/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import StoreKit

class PaymentViewCtrl: UIViewController {
    
    var Product30 : SKProduct!
    var Product60 : SKProduct!
    var Product90 : SKProduct!
    var Product300 : SKProduct!
    
    @IBOutlet weak var Coins30Btn: UIButton!
    @IBOutlet weak var Coins60Btn: UIButton!
    @IBOutlet weak var Coins90Btn: UIButton!
    @IBOutlet weak var Coins300Btn: UIButton!
    
    @IBOutlet weak var ItemFrame1: UIView!
    @IBOutlet weak var ItemFrame2: UIView!
    @IBOutlet weak var ItemFrame3: UIView!
    @IBOutlet weak var ItemFrame4: UIView!
    
    @IBOutlet weak var ProductStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ItemFrame1.layer.cornerRadius = 5
        ItemFrame2.layer.cornerRadius = 5
        ItemFrame3.layer.cornerRadius = 5
        ItemFrame4.layer.cornerRadius = 5
        
        Coins30Btn.layer.cornerRadius = 5
        Coins60Btn.layer.cornerRadius = 5
        Coins90Btn.layer.cornerRadius = 5
        Coins300Btn.layer.cornerRadius = 5
        
        DisableBtn()
        
        IAPManager.sharedInstance.FethingProducts { () -> () in
            self.Product30 = IAPManager.sharedInstance.GetProduct("ischool.iCoin30")
            self.Product60 = IAPManager.sharedInstance.GetProduct("ischool.iCoin60")
            self.Product90 = IAPManager.sharedInstance.GetProduct("ischool.iCoin90")
            self.Product300 = IAPManager.sharedInstance.GetProduct("ischool.iCoin300")
            
            self.EnableBtn()
            
            self.ProductStatus.text = "商品準備完畢,您可以開始購買"
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        IAPManager.sharedInstance.ClearCallback()
    }
    
    @IBAction func Buy30Coins(sender: AnyObject) {
        
        DisableBtn()
        IAPManager.sharedInstance.BuyProduct(Product30) { () -> () in
            self.ProductStatus.text = "現在餘額:" + GetCoinsBalance()
            self.EnableBtn()
        }
    }
    
    @IBAction func Buy60Coins(sender: AnyObject) {
        
        DisableBtn()
        IAPManager.sharedInstance.BuyProduct(Product60) { () -> () in
            self.ProductStatus.text = "現在餘額:" + GetCoinsBalance()
            self.EnableBtn()
        }
    }
    
    @IBAction func Buy90Coins(sender: AnyObject) {
        
        DisableBtn()
        IAPManager.sharedInstance.BuyProduct(Product90) { () -> () in
            self.ProductStatus.text = "現在餘額:" + GetCoinsBalance()
            self.EnableBtn()
        }
    }
    
    @IBAction func Buy300Coins(sender: AnyObject) {
        
        DisableBtn()
        IAPManager.sharedInstance.BuyProduct(Product300) { () -> () in
            self.ProductStatus.text = "現在餘額:" + GetCoinsBalance()
            self.EnableBtn()
        }
    }
    
    func EnableBtn(){
        self.Coins30Btn.enabled = self.Product30 == nil ? false : true
        self.Coins60Btn.enabled = self.Product60 == nil ? false : true
        self.Coins90Btn.enabled = self.Product90 == nil ? false : true
        self.Coins300Btn.enabled = self.Product300 == nil ? false : true
    }
    
    func DisableBtn(){
        Coins30Btn.enabled = false
        Coins60Btn.enabled = false
        Coins90Btn.enabled = false
        Coins300Btn.enabled = false
    }
    
}
