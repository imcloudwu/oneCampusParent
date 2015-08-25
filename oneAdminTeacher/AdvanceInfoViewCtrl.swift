////
////  AdvanceInfoViewCtrl.swift
////  oneAdminTeacher
////
////  Created by Cloud on 6/30/15.
////  Copyright (c) 2015 ischool. All rights reserved.
////
//
//import UIKit
//
//enum FuncType : String{
//    case Attendance = "缺曠查詢",Discipline = "獎懲查詢",ExamScore = "評量成績查詢",SemesterScore = "學期成績查詢"
//}
//
//class AdvanceInfoViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
//    
//    @IBOutlet weak var tableView: UITableView!
//    
//    var _funcItem = [FuncItem(Type: FuncType.Attendance, Icon: UIImage(named: "Today-32.png")),
//    FuncItem(Type: FuncType.Discipline, Icon: UIImage(named: "Diploma-32.png")),
//    FuncItem(Type: FuncType.ExamScore, Icon: UIImage(named: "Purchase Order-32.png")),
//    FuncItem(Type: FuncType.SemesterScore, Icon: UIImage(named: "Courses-32.png"))]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "DeleteStudent")
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "SelectStudent")
//        
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        ResetViewTitle()
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        return _funcItem.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
//        var cell = tableView.dequeueReusableCellWithIdentifier("funcCell") as? UITableViewCell
//        
//        if cell == nil{
//            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "funcCell")
//        }
//        
//        cell!.textLabel?.text = _funcItem[indexPath.row].Type.rawValue
//        cell!.imageView?.image = _funcItem[indexPath.row].Icon
//        //cell!.detailTextLabel?.text = _funcItem[indexPath.row].Name
//        return cell!
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
//        
//        if Global.CurrentStudent == nil{
//            ShowErrorAlert(self, "錯誤","請先選擇一名學生再進行查詢")
//            return
//        }
//        
//        switch _funcItem[indexPath.row].Type{
//        
//        case FuncType.Attendance:
//            
//            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("attendanceViewCtrl") as! AttendanceViewCtrl
//            nextView.StudentData = Global.CurrentStudent
//            
//            self.navigationController?.pushViewController(nextView, animated: true)
//        
//        case FuncType.Discipline:
//            
//            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("disciplineViewCtrl") as! DisciplineViewCtrl
//            nextView.StudentData = Global.CurrentStudent
//            
//            self.navigationController?.pushViewController(nextView, animated: true)
//            
//        case FuncType.ExamScore:
//            
//            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("examScoreViewCtrl") as! ExamScoreViewCtrl
//            nextView.StudentData = Global.CurrentStudent
//            
//            self.navigationController?.pushViewController(nextView, animated: true)
//            
//        case FuncType.SemesterScore:
//            
//            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("semesterScoreViewCtrl") as! SemesterScoreViewCtrl
//            nextView.StudentData = Global.CurrentStudent
//            
//            self.navigationController?.pushViewController(nextView, animated: true)
//            
//        default:
//            ShowErrorAlert(self, "錯誤","這功能尚未開放呦")
//        }
//    }
//    
//    func ResetViewTitle(){
//        if Global.CurrentStudent == nil && Global.Students.count > 0{
//            Global.CurrentStudent = Global.Students[0]
//        }
//        
//        if Global.CurrentStudent == nil{
//            self.navigationItem.title = "尚未選擇任何學生"
//        }
//        else{
//            self.navigationItem.title = Global.CurrentStudent.Name
//        }
//    }
//    
//    func DeleteStudent(){
//        let actionSheet = UIAlertController(title: "請選擇一位學生", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
//        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
//        
//        for stu in Global.Students{
//            let action = UIAlertAction(title: stu.DSNS + "_" + stu.Name, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
//                Global.DeleteStudent(stu)
//                //刪除此筆catch
//                StudentCoreData.DeleteStudent(stu)
//                self.ResetViewTitle()
//            })
//            
//            actionSheet.addAction(action)
//        }
//        
//        self.presentViewController(actionSheet, animated: true, completion: nil)
//    }
//    
//    func SelectStudent(){
//        
//        let actionSheet = UIAlertController(title: "請選擇一位學生", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
//        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
//        
//        for stu in Global.Students{
//            let action = UIAlertAction(title: stu.DSNS + "_" + stu.Name, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
//                Global.CurrentStudent = stu
//                self.ResetViewTitle()
//            })
//            
//            actionSheet.addAction(action)
//        }
//        
//        self.presentViewController(actionSheet, animated: true, completion: nil)
//    }
//}
//
//struct FuncItem{
//    var Type : FuncType
//    var Icon : UIImage!
//}