//
//  ChildListViewCtrl.swift
//  oneCampusParent
//
//  Created by Cloud on 8/21/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class ChildListViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    var refreshControl : UIRefreshControl!
    
    var DsnsResult = [String:Bool]()
    
    var progressTimer : ProgressTimer!
    
    var _Data = [Student]()
    
    //var addBtn : UIBarButtonItem!
    
    @IBAction func AddBtnClick(sender: AnyObject) {
        AddChild()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "ReloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        addBtn.layer.cornerRadius = addBtn.frame.size.width / 2
        addBtn.layer.masksToBounds = true
//        addBtn.layer.borderColor = UIColor.whiteColor().CGColor
//        addBtn.layer.borderWidth = 3.0
        
        //addBtn.backgroundColor = UIColor.clearColor()
        addBtn.layer.shadowColor = UIColor.darkGrayColor().CGColor
        addBtn.layer.shadowPath = UIBezierPath(roundedRect: addBtn.bounds, cornerRadius: addBtn.frame.size.width / 2).CGPath
        addBtn.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        addBtn.layer.shadowOpacity = 1.0
        addBtn.layer.shadowRadius = 2
        addBtn.clipsToBounds = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if Global.MyChildList != nil{
            _Data = Global.MyChildList
        }
        
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationItem.title = "我的孩子"
        
        if _Data.count == 0 || Global.NeedRefreshChildList{
            Global.NeedRefreshChildList = false
            ReloadData()
        }
    }
    
    func ReloadData(){
        
        self.refreshControl.endRefreshing()
        
        if !Global.HasPrivilege{
            ShowErrorAlert(self, "超過使用期限", "請安裝新版並進行點數加值")
            return
        }
        
        DsnsResult.removeAll(keepCapacity: false)
        for dsns in Global.DsnsList{
            DsnsResult[dsns.Name] = false
        }
        
        var tmpList = [Student]()
        
        progressTimer.StartProgress()
        
        if Global.DsnsList.count == 0{
            progressTimer.StopProgress()
        }
        
        for dsns in Global.DsnsList{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                var con = Connection()
                SetCommonConnect(dsns.AccessPoint, con)
                tmpList += self.GetMyChildren(con)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.DsnsResult[dsns.Name] = true
                    
                    self._Data = tmpList
                    
                    if self.AllDone(){
                        self.progressTimer.StopProgress()
                        
                        if tmpList.count == 0{
                            self.Notice()
                        }
                        
                        Global.MyChildList = self._Data
                    }
                    
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    func AllDone() -> Bool{
        
        for dsns in DsnsResult{
            if !dsns.1{
                return false
            }
        }
        
        return true
    }
    
    func Notice(){
        let subView = UILabel()
        subView.textColor = UIColor.grayColor()
        subView.textAlignment = NSTextAlignment.Center
        subView.text = "先加入您的小孩吧"
        subView.font = UIFont.systemFontOfSize(32.0)
        subView.frame = CGRectMake(0, 0, 300, 100)
        subView.center = self.view.center
        
        self.view.addSubview(subView)
        
        UIView.animateWithDuration(2.0, animations: { () -> Void in
            subView.center.y = 0
            
            }) { (Bool) -> Void in
                subView.removeFromSuperview()
        }

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _Data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _Data[indexPath.row]
        
        if data.DSNS == "header"{
            var cell = tableView.dequeueReusableCellWithIdentifier("summaryItem") as? UITableViewCell
            
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "summaryItem")
                cell?.backgroundColor = UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
            }
            
            cell?.textLabel?.text = data.ClassName
            return cell!
        }
    
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! StudentCell
        
        cell.Photo.image = data.Photo
        cell.Label1.text = data.Name
        cell.Label2.text = data.SeatNo == "" ? "" : "座號: \(data.SeatNo) "
        cell.student = data
        
        //UILongPressGestureRecognizer
        var longPress = UILongPressGestureRecognizer(target: self, action: "LongPress:")
        longPress.minimumPressDuration = 0.5
        
        cell.addGestureRecognizer(longPress)
        
        return  cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if _Data[indexPath.row].DSNS != "header"{
            
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentDetailViewCtrl") as! StudentDetailViewCtrl
            nextView.StudentData = _Data[indexPath.row]
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if _Data[indexPath.row].DSNS == "header"{
            return 30
        }
        
        return 72
    }
    
    //Mark : Delete Child Function
    func LongPress(sender:UILongPressGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began{
            var cell = sender.view as! StudentCell
            
            let menu = UIAlertController(title: "要刪除 \(cell.student.Name) 嗎?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            
            menu.addAction(UIAlertAction(title: "是", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                
                var con = GetCommonConnect(cell.student.DSNS)
                var err:DSFault!
                con.SendRequest("main.RemoveChild", bodyContent: "<Request><StudentParent><StudentID>\(cell.student.ID)</StudentID></StudentParent></Request>", &err)
                
                if err != nil{
                    ShowErrorAlert(self, "刪除失敗", err.message)
                }
                else{
                    ShowErrorAlert(self, "刪除成功", "")
                }
                
                self.ReloadData()
            }))
            
            self.presentViewController(menu, animated: true, completion: nil)
        }
    }
    
    func ToggleSideMenu(){
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func AddChild(){
        let actionSheet = UIAlertController(title: "要加入您的小孩嗎?", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "代碼掃描", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("ScanCodeViewCtrl") as! ScanCodeViewCtrl
            self.navigationController?.pushViewController(nextView, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "手動輸入", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("KeyinViewCtrl") as! KeyinViewCtrl
            self.navigationController?.pushViewController(nextView, animated: true)
        }))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func GetMyChildren(con:Connection) -> [Student]{
        
        var err : DSFault!
        var nserr : NSError?
        
        var retVal = [Student]()
        
        var rsp = con.sendRequest("main.GetMyChildren", bodyContent: "", &err)
        
        //println(rsp)
        
        if err != nil{
            //ShowErrorAlert(self,"取得資料發生錯誤",err.message)
            return retVal
        }
        
        let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let students = xml?.root["Student"].all {
            for stu in students{
                //println(stu.xmlString)
                let studentID = stu["StudentId"].stringValue
                let className = stu["ClassName"].stringValue
                let studentName = stu["StudentName"].stringValue
                let seatNo = stu["SeatNo"].stringValue
                let studentNumber = stu["StudentNumber"].stringValue
                let gender = stu["Gender"].stringValue
                let mailingAddress = stu["MailingAddress"].xmlString
                let permanentAddress = stu["PermanentAddress"].xmlString
                let contactPhone = stu["ContactPhone"].stringValue
                let permanentPhone = stu["PermanentPhone"].stringValue
                let custodianName = stu["CustodianName"].stringValue
                let fatherName = stu["FatherName"].stringValue
                let motherName = stu["MotherName"].stringValue
                let freshmanPhoto = GetImageFromBase64String(stu["StudentPhoto"].stringValue, UIImage(named: "User-100.png"))
                
                let stuItem = Student(DSNS: con.accessPoint,ID: studentID, ClassID: "", ClassName: className, Name: studentName, SeatNo: seatNo, StudentNumber: studentNumber, Gender: gender, MailingAddress: mailingAddress, PermanentAddress: permanentAddress, ContactPhone: contactPhone, PermanentPhone: permanentPhone, CustodianName: custodianName, FatherName: fatherName, MotherName: motherName, Photo: freshmanPhoto)
                
                retVal.append(stuItem)
            }
        }
        
        retVal.sort{ $0.SeatNo.toInt() < $1.SeatNo.toInt() }
        
        if retVal.count > 0{
            
            let schoolName = GetSchoolName(con)
            
            retVal.insert(Student(DSNS: "header", ID: "", ClassID: "", ClassName: schoolName, Name: "", SeatNo: "", StudentNumber: "", Gender: "", MailingAddress: "", PermanentAddress: "", ContactPhone: "", PermanentPhone: "", CustodianName: "", FatherName: "", MotherName: "", Photo: nil), atIndex: 0)
        }
        
        return retVal
    }
}