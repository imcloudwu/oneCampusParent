////
////  FirstViewController.swift
////  oneAdminTeacher
////
////  Created by Cloud on 6/12/15.
////  Copyright (c) 2015 ischool. All rights reserved.
////
//
//import UIKit
//
//class ExamScoreViewCtrl : UIViewController,UITableViewDelegate,UITableViewDataSource {
//    
//    @IBOutlet weak var tableView: UITableView!
//    
//    var _data = [ExamScoreItem]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        _data.append(ExamScoreItem(Domain: "語文", Subject: "", Credit: "", ScoreA: "", ScoreB: "", ScoreC: "88.88"))
//        _data.append(ExamScoreItem(Domain: "語文", Subject: "國語", Credit: "3", ScoreA: "90", ScoreB: "100", ScoreC: "95"))
//        _data.append(ExamScoreItem(Domain: "語文", Subject: "英文", Credit: "3", ScoreA: "80", ScoreB: "70", ScoreC: "75"))
//        
//        _data.append(ExamScoreItem(Domain: "社會", Subject: "", Credit: "", ScoreA: "", ScoreB: "", ScoreC: "99.99"))
//        _data.append(ExamScoreItem(Domain: "社會", Subject: "社會", Credit: "2", ScoreA: "100", ScoreB: "80", ScoreC: "90"))
//        
//        _data.append(ExamScoreItem(Domain: "自然", Subject: "", Credit: "", ScoreA: "", ScoreB: "", ScoreC: "77.77"))
//        _data.append(ExamScoreItem(Domain: "自然", Subject: "地球科學", Credit: "3", ScoreA: "90", ScoreB: "100", ScoreC: "95"))
//        _data.append(ExamScoreItem(Domain: "自然", Subject: "生活物理", Credit: "2", ScoreA: "70", ScoreB: "80", ScoreC: "75"))
//        
//        self.navigationItem.title = "評量成績"
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        return _data.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
//        
//        let data = _data[indexPath.row]
//        
//        if data.Subject == ""{
//            let cell = tableView.dequeueReusableCellWithIdentifier("examScoreTitleCell") as! ExamScoreTitleCell
//            cell.Domain.text = _data[indexPath.row].Domain
//            cell.Score.text = _data[indexPath.row].ScoreC
//            
//            return cell
//        }
//        else{
//            let cell = tableView.dequeueReusableCellWithIdentifier("examScoreCell") as! ExamScoreCell
//            cell.Subject.text = _data[indexPath.row].Subject
//            cell.ScoreA.text = _data[indexPath.row].ScoreA
//            cell.ScoreB.text = _data[indexPath.row].ScoreB
//            cell.ScoreC.text = _data[indexPath.row].ScoreC
//            cell.Credit.text = _data[indexPath.row].Credit
//            
//            return cell
//        }
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
//        
//        let data = _data[indexPath.row]
//        
//        if data.Subject == ""{
//            return 40
//        }
//        else{
//            return 60
//        }
//    }
//    
//    
//}
//
//struct ExamScoreItem {
//    var Domain:String!
//    var Subject:String!
//    var Credit:String!
//    var ScoreA:String!
//    var ScoreB:String!
//    var ScoreC:String!
//}
//
