//
//  IAPManager.swift
//  oneCampusParent
//
//  Created by Cloud on 9/2/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation
import StoreKit

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    private var _Products : [String:SKProduct]!
    
    private var _FethingProductsCallBack : (() -> ())?
    private var _PurchasedProductsCallBack : (() -> ())?
    
    let productIds = Set(["ischool.iCoin30","ischool.iCoin60","ischool.iCoin90","ischool.iCoin300"])
    
    class var sharedInstance : IAPManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: IAPManager?
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = IAPManager()
        }
        return Static.instance!
    }
    
    override init(){
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    func AddCoins(charge:Int){
        
        if let myCoins = Keychain.load("myCoins")?.stringValue{
            if let coinValue = Int(myCoins){
                let newValue = coinValue + charge
                
                Keychain.save("myCoins", data: "\(newValue)".dataValue)
            }
        }
        else{
            Keychain.save("myCoins", data: "\(charge)".dataValue)
        }
    }
    
    private func ExcutePurchasedProductsCallBack(){
        if let callback = _PurchasedProductsCallBack{
            callback()
        }
    }
    
    func ClearCallback(){
        _FethingProductsCallBack = nil
        _PurchasedProductsCallBack = nil
    }
    
    func FethingProducts(callback:() -> ()){
        if SKPaymentQueue.canMakePayments(){
            let productsRequest = SKProductsRequest(productIdentifiers: self.productIds)
            productsRequest.delegate = self
            productsRequest.start()
            
            _FethingProductsCallBack = callback
        }
    }
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        let count : Int = response.products.count
        
        if (count>0) {
            
            var tmps = [String:SKProduct]()
            
            var validProducts = response.products
            
            for products in response.products {
                
                if let validProduct = products as? SKProduct{
                    //                    println(validProduct.localizedTitle)
                    //                    println(validProduct.localizedDescription)
                    //                    println(validProduct.price)
                    
                    tmps[validProduct.productIdentifier] = validProduct
                }
            }
            
            _Products = tmps
        }
        
        if let callback = _FethingProductsCallBack{
            callback()
        }
    }
    
    func GetProduct(productid:String) -> SKProduct?{
        if let p = _Products[productid] {
            return p
        }
        
        return nil
    }
    
    func BuyProduct(product:SKProduct,callback:(() -> ())!){
        SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: product))
        
        _PurchasedProductsCallBack = callback
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
        
        if let trans = transactions as? [SKPaymentTransaction]{
            
            for tran in trans{
                
                switch tran.transactionState {
                    
                case .Purchased:
                    
                    print("Product Purchased")
                    SKPaymentQueue.defaultQueue().finishTransaction(tran)
                    break
                    
                case .Restored:
                    
                    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
                    break
                    
                case .Failed:
                    
                    print("Purchased Failed")
                    SKPaymentQueue.defaultQueue().finishTransaction(tran)
                    break
                    
                case .Purchasing:
                    print("Product Purchasing")
                    break
                    
                case .Deferred:
                    print("Product Deferred")
                    break
                    
                default:
                    break
                }
            }
            
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]){
        
        if let trans = transactions as? [SKPaymentTransaction]{
            
            for tran in trans{
                
                if tran.transactionState == .Purchased{
                    print("即將完成購物品的移除")
                    print("\(tran.payment.productIdentifier)")
                    
                    switch tran.payment.productIdentifier{
                        
                    case "ischool.iCoin30":
                        AddCoins(30)
                        break
                        
                    case "ischool.iCoin60":
                        AddCoins(60)
                        break
                        
                    case "ischool.iCoin90":
                        AddCoins(90)
                        break
                        
                    case "ischool.iCoin300":
                        AddCoins(300)
                        break
                        
                    default:
                        break
                    }
                }
            }
        }
        
        ExcutePurchasedProductsCallBack()
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError){
        print("Restoring failed cause \(error)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue){
        
        for transaction:SKPaymentTransaction in queue.transactions {
        }
        
        let alert = UIAlertView(title: "Thank You", message: "Your purchase(s) were restored.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
}
