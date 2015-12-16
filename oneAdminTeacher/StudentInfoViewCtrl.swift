//
//  StudentInfoViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/29/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentInfoViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,ContainerViewProtocol {
    
    var StudentData:Student!
    var ParentNavigationItem : UINavigationItem?
    var AddBtn : UIBarButtonItem!
    
    var _displayData = [DisplayItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: 96.0/255, green: 125.0/255, blue: 139.0/255, alpha: 1.0)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //self.automaticallyAdjustsScrollViewInsets = true
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "加入清單", style: UIBarButtonItemStyle.Plain, target: self, action: "AddToList")
        AddBtn = UIBarButtonItem(image: UIImage(named: "Add User-25.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "AddToList")
        //ParentNavigationItem?.rightBarButtonItems?.append(AddBtn)
        
        _displayData.append(DisplayItem(Title: "性別", Value: StudentData.Gender, OtherInfo: "", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "監護人", Value: StudentData.CustodianName, OtherInfo: "", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "父親姓名", Value: StudentData.FatherName, OtherInfo: "", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "母親姓名", Value: StudentData.MotherName, OtherInfo: "", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "戶籍電話", Value: StudentData.PermanentPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "聯絡電話", Value: StudentData.ContactPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "戶籍地址", Value: GetAddress(StudentData.PermanentAddress), OtherInfo: "address", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "郵遞地址", Value: GetAddress(StudentData.MailingAddress), OtherInfo: "address", ColorAlarm: false))
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        LockBtnEnableCheck()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let data = _displayData[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentBasicInfoCell") as! StudentBasicInfoCell
        
        cell.Title.text = data.Title
        cell.Value.text = data.Value
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let data = _displayData[indexPath.row]
        
        if data.OtherInfo == "phoneNumber"{
            DialNumber(data.Value)
        }
        
        if data.OtherInfo == "address"{
            GoogleMap(data.Value)
        }
    }
    
    func AddToList(){
        Global.Students.append(StudentData)
        LockBtnEnableCheck()
        
        //存入catch
        StudentCoreData.SaveCatchData(StudentData)
    }
    
    func GetAddress(xmlString:String) -> String{
        var nserr : NSError?
        let xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: xmlString.dataValue)
        } catch _ {
            xml = nil
        }
        
        var retVal = ""
        
        if let addresses = xml?.root["AddressList"]["Address"].all{
            for address in addresses{
                
                let zipCode = address["ZipCode"].stringValue == "" ? "" : "[" + address["ZipCode"].stringValue + "]"
                let county = address["County"].stringValue
                let town = address["Town"].stringValue
                let detailAddress = address["DetailAddress"].stringValue
                
                retVal = zipCode + county + town + detailAddress
                
                if retVal != ""{
                    return retVal
                }
            }
        }
        
        return "查無地址資料"
    }
    
    func DialNumber(phoneNumber:String){
        if let urlEncoding = phoneNumber.UrlEncoding{
            let phone = "telprompt://" + urlEncoding
            let url:NSURL = NSURL(string:phone)!
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func GoogleMap(address:String){
        
        if let urlEncoding = address.UrlEncoding{
            
            let appleMap = "http://maps.apple.com/?q=\(urlEncoding)"
            let appleUrl:NSURL = NSURL(string:appleMap)!
            
            let alert = UIAlertController(title: "繼續？", message: "即將開啟Apple map", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (okaction) -> Void in
                UIApplication.sharedApplication().openURL(appleUrl)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
//            let mapLink = "comgooglemapsurl://www.google.com.tw/maps/place/" + urlEncoding
//            let url:NSURL = NSURL(string:mapLink)!
            
//            if UIApplication.sharedApplication().canOpenURL(url) {
//                UIApplication.sharedApplication().openURL(url)
//            }
//            else{
//                var alert = UIAlertController(title: "繼續?", message: "需要安裝Google Map才能進行", preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (okaction) -> Void in
//                    let itunes = "https://itunes.apple.com/app/id585027354"
//                    let itunesUrl:NSURL = NSURL(string:itunes)!
//                    UIApplication.sharedApplication().openURL(itunesUrl)
//                }))
//                
//                self.presentViewController(alert, animated: true, completion: nil)
//            }
        }
    }
    
    func LockBtnEnableCheck(){
        if Global.Students.contains(StudentData){
            AddBtn.enabled = false
        }
        else{
            AddBtn.enabled = true
        }
    }
}
