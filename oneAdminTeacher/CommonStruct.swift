//
//  CommonStruct.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/7/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation

//struct DisplayItem{
//    var Title : String
//    var Value : String
//    var OtherInfo : String
//    var ColorAlarm : Bool
//}

class DisplayItem{
    var Title : String
    var Value : String
    var OtherInfo : String
    var OtherInfo2 : String
    var OtherInfo3 : String
    var ColorAlarm : Bool
    
    convenience init(Title:String,Value:String,OtherInfo:String,ColorAlarm:Bool){
        
        self.init(Title:Title,Value:Value,OtherInfo:OtherInfo,OtherInfo2:"",OtherInfo3:"",ColorAlarm:ColorAlarm)
    }
    
    init(Title:String,Value:String,OtherInfo:String,OtherInfo2:String,OtherInfo3:String,ColorAlarm:Bool){
        self.Title = Title
        self.Value = Value
        self.OtherInfo = OtherInfo
        self.OtherInfo2 = OtherInfo2
        self.OtherInfo3 = OtherInfo3
        self.ColorAlarm = ColorAlarm
    }
}

protocol SemesterProtocol
{
    var SchoolYear : String { get set }
    var Semester : String { get set }
}

protocol ContainerViewProtocol
{
    var StudentData : Student! { get set }
    var ParentNavigationItem : UINavigationItem? { get set }
}

class TeacherAccount : Equatable{
    var SchoolName : String
    var Name : String
    var Account : String
    var UUID : String
    
    init(schoolName:String,name:String,account:String){
        SchoolName = schoolName
        Name = name
        Account = account
        UUID = ""
    }
    
    //    init(uuid:String){
    //        SchoolName = ""
    //        Name = ""
    //        Account = ""
    //        UUID = uuid
    //    }
}

func ==(lhs: TeacherAccount, rhs: TeacherAccount) -> Bool {
    return lhs.SchoolName == rhs.SchoolName && lhs.Name == rhs.Name && lhs.Account == rhs.Account
}

//Mark : My Toast Class
class Toast {
    
    var container: UIView = UIView()
    var Message: UILabel = UILabel()
    
    /*
    Show customized activity indicator,
    actually add activity indicator to passing view
    
    @param uiView - add activity indicator to this view
    */
    func ToastMessage(uiView: UIView,callback:(() -> ())) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        
        Message.text = "傳送完成..."
        Message.alpha = 1
        Message.textColor = UIColor.whiteColor()
        Message.textAlignment = NSTextAlignment.Center
        Message.frame = CGRectMake(0, 0, 200, 50)
        Message.center = container.center
        Message.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        Message.layer.masksToBounds = true
        Message.layer.cornerRadius = 10
        
        container.addSubview(Message)
        uiView.addSubview(container)
        
        UIView.animateWithDuration(1.5, animations: { () -> Void in
            self.Message.alpha = 0
        }) { (success) -> Void in
            self.container.removeFromSuperview()
            
            callback()
        }
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}

