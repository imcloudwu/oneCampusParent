//
//  PurchaseViewCtrl.swift
//  oneCampusParent
//
//  Created by Cloud on 8/27/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class PurchaseViewCtrl: UIViewController {
    
    @IBOutlet weak var oneMothBtn: UIButton!
    @IBOutlet weak var sixMothBtn: UIButton!
    
    @IBOutlet weak var MyCoinsBalance: UILabel!
    @IBOutlet weak var MyServiceDeadline: UILabel!
    
    var Deadline : NSDate!
    var DateFormater : NSDateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Deadline = NSDate()
        DateFormater = NSDateFormatter()
        DateFormater.dateFormat = "yyyy/MM/dd"
        
        self.navigationItem.title = "購買服務"
        
        oneMothBtn.layer.cornerRadius = 5
        sixMothBtn.layer.cornerRadius = 5
        
        CheckCoinsAndDeadline()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        MyCoinsBalance.text = GetCoinsBalance()
    }
    
    @IBAction func BuyMoreCoins(sender: AnyObject) {
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PaymentViewCtrl") as! PaymentViewCtrl
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @IBAction func oneMonthBtnClick(sender: AnyObject) {
        if let myCoins = Keychain.load("myCoins")?.stringValue{
            if let coinValue = Int(myCoins) where coinValue >= 60 {
                let balance = coinValue - 60
                
                Keychain.save("myCoins", data: "\(balance)".dataValue)
                MyCoinsBalance.text = "\(balance)"
                
                let date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Month, value: 1, toDate: Deadline, options: [])!
                MyServiceDeadline.text = DateFormater.stringFromDate(date)
                Deadline = date
            }
        }
    }
    
    @IBAction func sixMonthBtnClick(sender: AnyObject) {
        if let myCoins = Keychain.load("myCoins")?.stringValue{
            if let coinValue = Int(myCoins) where coinValue >= 300 {
                let balance = coinValue - 300
                
                Keychain.save("myCoins", data: "\(balance)".dataValue)
                MyCoinsBalance.text = "\(balance)"
                
                let date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Month, value: 6, toDate: Deadline, options: [])!
                MyServiceDeadline.text = DateFormater.stringFromDate(date)
                Deadline = date
            }
        }
    }
    
    func CheckCoinsAndDeadline(){
        MyServiceDeadline.text = DateFormater.stringFromDate(Deadline)
    }
}