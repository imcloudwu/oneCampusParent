//
//  SelectSchoolViewCtrl.swift
//  oneCampusParent
//
//  Created by Cloud on 2016/1/26.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class SelectSchoolViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var _SelectedSchool : DsnsItem!
    
    var _SchoolLists = [DsnsItem]()
    
    var _DisplaySchool = [DsnsItem]()
    
    var _Locations = [String]()
    
    var _Types = [String]()
    
    var _CurrentLocation = ""
    var _CurrentType = ""
    
    @IBOutlet weak var locationBtn: UIButton!
    
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func locationBtnClick(sender: AnyObject) {
        
        let menu = UIAlertController(title: "請選擇地區", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for location in _Locations{
            
            menu.addAction(UIAlertAction(title: location, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                
                self._CurrentLocation = location
                
                self.locationBtn.setTitle(self._CurrentLocation, forState: UIControlState.Normal)
                
                self.FilterData()
            }))
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    @IBAction func typeBtnClick(sender: AnyObject) {
        
        let menu = UIAlertController(title: "請選擇學制", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for type in _Types{
            
            menu.addAction(UIAlertAction(title: type, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                
                self._CurrentType = type
                
                self.typeBtn.setTitle(self._CurrentType, forState: UIControlState.Normal)
                
                self.FilterData()
            }))
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let rsp = try? HttpClient.Get("https://1campus.net/schoollist.xml")
        
        let xml = try? AEXMLDocument(xmlData: rsp!)
        
        if let schools = xml?.root["School"].all{
            
            for school in schools{
                
                if let name = school.attributes["SchoolName"],let accessPoint = school.attributes["DSNS"],let type = school.attributes["Type"], let county = school.attributes["County"]{
                    
                    let dsns = DsnsItem(name: name, accessPoint: accessPoint)
                    dsns.Location = county
                    dsns.Type = type
                    
                    _SchoolLists.append(dsns)
                    
                    if !_Locations.contains(county){
                        _Locations.append(county)
                    }
                    
                    if !_Types.contains(type){
                        _Types.append(type)
                    }
                }
            }
            
            let dev = DsnsItem(name: "測試開發", accessPoint: "dev.sh_d")
            dev.Location = "新竹市"
            dev.Type = "高中職"
            
            _SchoolLists.insert(dev, atIndex: 0)
            
            _DisplaySchool = _SchoolLists
            
            self.tableView.reloadData()
            
            animatedWithTableView(self.tableView)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func FilterData(){
        
        let founds = self._SchoolLists.filter({ (school) -> Bool in
            
            if !self._CurrentLocation.isEmpty && !self._CurrentType.isEmpty{
                
                if school.Location == self._CurrentLocation && school.Type == self._CurrentType{
                    return true
                }
            }
            else if !self._CurrentLocation.isEmpty{
                
                if school.Location == self._CurrentLocation{
                    return true
                }
            }
            else{
                
                if school.Type == self._CurrentType{
                    return true
                }
            }
            
            return false
        })
        
        self._DisplaySchool = founds
        
        self.tableView.reloadData()
        
        animatedWithTableView(self.tableView)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       return _DisplaySchool.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
    
        let data = _DisplaySchool[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("schoolCell")
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "schoolCell")
        }
        
        cell?.textLabel?.text = data.Name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = _DisplaySchool[indexPath.row]
        
        self._SelectedSchool.Name = data.Name
        self._SelectedSchool.AccessPoint = data.AccessPoint
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    
}

