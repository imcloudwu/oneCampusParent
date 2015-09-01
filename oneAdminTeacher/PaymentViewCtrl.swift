//
//  PurchaseViewCtrl.swift
//  oneCampusParent
//
//  Created by Cloud on 8/27/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import StoreKit

class PaymentViewCtrl: UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    var _Products : [String:SKProduct]!
    
    let productIdentifiers = Set(["ischool.iCoin30","ischool.iCoin60","ischool.iCoin90","ischool.iCoin300"])
    
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
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        ItemFrame1.layer.cornerRadius = 5
        ItemFrame2.layer.cornerRadius = 5
        ItemFrame3.layer.cornerRadius = 5
        ItemFrame4.layer.cornerRadius = 5
        
        Coins30Btn.layer.cornerRadius = 5
        Coins60Btn.layer.cornerRadius = 5
        Coins90Btn.layer.cornerRadius = 5
        Coins300Btn.layer.cornerRadius = 5
        Coins30Btn.enabled = false
        Coins60Btn.enabled = false
        Coins90Btn.enabled = false
        Coins300Btn.enabled = false
        
        _Products = [String:SKProduct]()
        
        if SKPaymentQueue.canMakePayments(){
            FethingProducts()
        }
        //RestorePurchases()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    @IBAction func Buy30Coins(sender: AnyObject) {
        if let p = _Products["ischool.iCoin30"] {
            SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: p))
        }
    }
    
    @IBAction func Buy60Coins(sender: AnyObject) {
        if let p = _Products["ischool.iCoin60"] {
            SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: p))
        }
    }
    
    @IBAction func Buy90Coins(sender: AnyObject) {
        if let p = _Products["ischool.iCoin90"] {
            SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: p))
        }
    }
    
    @IBAction func Buy300Coins(sender: AnyObject) {
        if let p = _Products["ischool.iCoin300"] {
            SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: p))
        }
    }
    
    @IBAction func GoRemoveAd(sender: AnyObject) {
        if let p = _Products["ischool.removead"] {
            SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: p))
        }
    }
    
    @IBAction func GoBuy(sender: AnyObject) {
        if let p = _Products["ischool.iCoin30"] {
            SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: p))
        }
    }
    
    func RestorePurchases() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func FethingProducts(){
        let productsRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers as Set<NSObject>)
        productsRequest.delegate = self
        productsRequest.start()
        println("Fething Products")
    }
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        
        if transaction.payment.productIdentifier == "ischool.iCoin30"{
            AddCoins(30)
        }
        else if transaction.payment.productIdentifier == "ischool.iCoin60"{
            AddCoins(60)
        }
        else if transaction.payment.productIdentifier == "ischool.iCoin90"{
            AddCoins(90)
        }
        else if transaction.payment.productIdentifier == "ischool.iCoin300"{
            AddCoins(300)
        }
    }
    
    func AddCoins(charge:Int){
        
        var v = Keychain.load("myCoins")?.stringValue
        println("add \(charge) charge to \(v)")
        
        if let myCoins = Keychain.load("myCoins")?.stringValue{
            if let coinValue = myCoins.toInt(){
                let newValue = coinValue + charge
                
                Keychain.save("myCoins", data: "\(newValue)".dataValue)
                ProductStatus.text = "現在餘額: \(newValue)"
            }
        }
        else{
            Keychain.save("myCoins", data: "\(charge)".dataValue)
            ProductStatus.text = "現在餘額: \(charge)"
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!){
        println("Received Payment Transaction Response from Apple");
        
        if let trans = transactions as? [SKPaymentTransaction]{
            
            for tran in trans{
                
                switch tran.transactionState {
                    
                case .Purchased:
                    
                    println("Product Purchased")
                    deliverProduct(tran)
                    SKPaymentQueue.defaultQueue().finishTransaction(tran)
                    break
                    
                case .Restored:
                    
                    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
                    break
                    
                case .Failed:
                    
                    println("Purchased Failed")
                    SKPaymentQueue.defaultQueue().finishTransaction(tran)
                    break
                    
                default:
                    break
                }
            }
            
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!){
        println("Transactions Restored")
        
        //var purchasedItemIDS = []
        for transaction:SKPaymentTransaction in queue.transactions as! [SKPaymentTransaction] {
            
            deliverProduct(transaction)
        }
        
        var alert = UIAlertView(title: "Thank You", message: "Your purchase(s) were restored.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        println("got the request from Apple")
        
        println(response.invalidProductIdentifiers)
        
        var count : Int = response.products.count
        
        if (count>0) {
            
            var tmps = [String:SKProduct]()
            
            var validProducts = response.products
            
            for products in response.products {
                
                if let validProduct = products as? SKProduct{
                    println(validProduct.localizedTitle)
                    println(validProduct.localizedDescription)
                    println(validProduct.price)
                    
                    tmps[validProduct.productIdentifier] = validProduct
                }
            }
            
            _Products = tmps
        }
        
        SetProductItem()
    }
    
    func SetProductItem(){
        
        for product in _Products.values.array{
            
            switch product.productIdentifier{
                
            case "ischool.iCoin30":
                
                self.Coins30Btn.enabled = true
                break
                
            case "ischool.iCoin60":
                
                self.Coins60Btn.enabled = true
                break
                
            case "ischool.iCoin90":
                
                self.Coins90Btn.enabled = true
                break
                
            case "ischool.iCoin300":
                
                self.Coins300Btn.enabled = true
                break
                
            default:
                break
                
            }
        }
        
        var coins = 0
        if let myCoins = Keychain.load("myCoins")?.stringValue{
            if let coinValue = myCoins.toInt(){
                coins = coinValue
            }
        }
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.ProductStatus.text = "現在餘額: \(coins)"
        })
        
    }
}
