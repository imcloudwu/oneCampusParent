//
//  FirstViewController.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

//import UIKit
//
//class ssSemesterScoreViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
//    
//    @IBOutlet weak var CreditA: UILabel!
//    @IBOutlet weak var CreditB: UILabel!
//    @IBOutlet weak var PartA: UILabel!
//    @IBOutlet weak var SchoolA: UILabel!
//    @IBOutlet weak var PartB: UILabel!
//    @IBOutlet weak var SchoolB: UILabel!
//    @IBOutlet weak var Practice: UILabel!
//    @IBOutlet weak var Summary: UILabel!
//    @IBOutlet weak var tableView: UITableView!
//    
//    var _data = [SemesterScoreItem]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        self.navigationItem.title = "學期成績"
//        
//        CreditA.text = "10"
//        CreditB.text = "20"
//        PartA.text = "30"
//        PartB.text = "40"
//        SchoolA.text = "50"
//        SchoolB.text = "60"
//        Practice.text = "70"
//        Summary.text = "100 / 20"
//        
//        _data.append(SemesterScoreItem(Subject: "國文", Credit: "10", Score: "100", Type: "校定必修"))
//        _data.append(SemesterScoreItem(Subject: "英文", Credit: "2", Score: "50", Type: "校定選修"))
//        _data.append(SemesterScoreItem(Subject: "數學", Credit: "3", Score: "80", Type: "部定必修"))
//        _data.append(SemesterScoreItem(Subject: "化學", Credit: "4", Score: "80", Type: "部定選修"))
//        _data.append(SemesterScoreItem(Subject: "物理", Credit: "5", Score: "70", Type: "校定必修"))
//        _data.append(SemesterScoreItem(Subject: "美術", Credit: "6", Score: "60", Type: "校定必修"))
//        _data.append(SemesterScoreItem(Subject: "地球科學", Credit: "7", Score: "40", Type: "校定必修"))
//        _data.append(SemesterScoreItem(Subject: "健康教育", Credit: "8", Score: "30", Type: "校定必修"))
//        _data.append(SemesterScoreItem(Subject: "中國歷史", Credit: "9", Score: "20", Type: "校定必修"))
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
//        let cell = tableView.dequeueReusableCellWithIdentifier("semesterScoreCell") as! SemesterScoreCell
//        cell.Subject.text = _data[indexPath.row].Subject
//        cell.Info.text = "學分: \(_data[indexPath.row].Credit)   成績: \(_data[indexPath.row].Score)"
//        cell.Type.text = _data[indexPath.row].Type
//        
//        return cell
//    }
//}

//struct SemesterScoreItem{
//    var Subject:String!
//    var Credit:String!
//    var Score:String!
//    var Type:String!
//}

