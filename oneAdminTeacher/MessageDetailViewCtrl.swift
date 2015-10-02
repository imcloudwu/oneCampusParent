//
//  MessageDetailViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/22/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class MessageDetailViewCtrl: UIViewController{
    
    var MessageData : MessageItem!
    var SenderMode = false
    
    var Options = [VoteItem]()
    var Answers = [Int]()
    
    var MustVote = false
    var CanMultiple = false
    
    @IBOutlet weak var MessageTitle: UILabel!
    
    @IBOutlet weak var DsnsName: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var HyperLinkView: UIView!
    @IBOutlet weak var HyperLink: UILabel!
    
    @IBOutlet weak var HyperLinkViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var StatusBtn: UIButton!
    @IBOutlet weak var StatusBtnHeight: NSLayoutConstraint!
    
    @IBOutlet weak var NameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var ContentLabel: UILabel!
    
    var OptionLabels = [UILabel]()
    
    var onceToken: dispatch_once_t = 0
    
    @IBAction func StatusBtnClick(sender: AnyObject) {
        self.WatchReaderList()
    }
    
    var ReadersCatch = [String:String]()
    var ReadList = [String]()
    
    var _dateFormate = NSDateFormatter()
    var _timeFormate = NSDateFormatter()
    
    var _today : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //設為已讀
        NotificationService.SetRead(MessageData.Id, accessToken: Global.AccessToken)
        
        CanMultiple = MessageData.Type == "multiple" ? true : false
        
        GetMessageOptions()
        
        if SenderMode{
            
            UpdateMessage()
            
            if MessageData.Type != "normal"{
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "問卷統計", style: UIBarButtonItemStyle.Done, target: self, action: "ViewChart")
            }
        }
        else{
            
            //收件者模式隱藏已讀狀態
            StatusBtn.hidden = true
            StatusBtnHeight.constant = 0
            
            if MessageData.Type != "normal"{
                //有投過的訊息,按鈕長不一樣
                if MessageData.Voted{
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "進行投票", style: UIBarButtonItemStyle.Plain, target: self, action: "Vote")
                    //self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Starred Ticket Filled-25.png"), style: UIBarButtonItemStyle.Done, target: self, action: "Vote")
                }
                else{
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "進行投票", style: UIBarButtonItemStyle.Done, target: self, action: "Vote")
                    //self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Starred Ticket-25.png"), style: UIBarButtonItemStyle.Done, target: self, action: "Vote")
                }
            }
        }
        
        //資料初始化
        _dateFormate.dateFormat = "yyyy/MM/dd"
        _timeFormate.dateFormat = "HH:mm"
        
        _today = _dateFormate.stringFromDate(NSDate())
        
        let date = _dateFormate.stringFromDate(MessageData.Date)
        
        HyperLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "OpenUrl"))
        
        MessageTitle.text = MessageData.Title
        
        DsnsName.text = MessageData.DsnsName
        Name.text = MessageData.Name
        Date.text = _today == date ? _timeFormate.stringFromDate(MessageData.Date) : date
        HyperLink.text = MessageData.Redirect
        
        if Name.text == ""{
            Name.hidden = true
            NameHeight.constant = 0
        }
        
        if MessageData.Redirect == ""{
            HyperLinkView.hidden = true
            HyperLinkViewHeight.constant = 0
        }
        
        //Set attrString
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        var attrString = NSMutableAttributedString(string: MessageData.Content)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        ContentLabel.attributedText = attrString
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        //前一個畫面已經將isNew設定過了,直接儲存
        MessageCoreData.SaveCatchData(MessageData)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //only one time
        dispatch_once(&onceToken) { () -> Void in
            self.InitUIControl()
        }
    }
    
    func InitUIControl(){
        
        var yPosition : CGFloat = 0.0
        
        //self.view.layoutIfNeeded()
        
        yPosition += ContentLabel.bounds.size.height + 30
        
        if Options.count > 1{
            for index in 0...Options.count - 1 {
                
                let newLabel = UILabel()
                newLabel.layer.masksToBounds = true
                newLabel.layer.cornerRadius = 5
                newLabel.userInteractionEnabled = true
                newLabel.tag = index
                newLabel.numberOfLines = 0
                
                if let tmp = find(Answers, index){
                    newLabel.text = " ☑ " + Options[index].Title
                }
                else{
                    newLabel.text = " ☐ " + Options[index].Title
                }
                
                //newLabel.backgroundColor = UIColor(red: 0.0/255, green: 150.0/255, blue: 136.0/255, alpha: 0.1)
                newLabel.frame.size.width = ContentLabel.frame.size.width
                newLabel.frame.size.height = 48.0
                newLabel.frame.origin.x = ContentLabel.frame.origin.x
                newLabel.frame.origin.y = yPosition
                
                let bestSize = newLabel.sizeThatFits(CGSizeMake(newLabel.frame.size.width, newLabel.frame.size.height))
                newLabel.frame.size.height = bestSize.height > 48.0 ? bestSize.height : 48.0
                
                yPosition += newLabel.frame.size.height + 10
                
                let tapGesture = UITapGestureRecognizer(target: self, action: "TapOption:")
                newLabel.addGestureRecognizer(tapGesture)
                
                OptionLabels.append(newLabel)
                ScrollView.addSubview(newLabel)
            }
        }
        
        if yPosition > ScrollView.contentSize.height{
            ScrollView.contentSize.height = yPosition
        }
    }
    
    func TapOption(sender : UITapGestureRecognizer){
        let view = sender.view as! UILabel
        //println("u pressed number : \(view.tag) option")
        
        if CanMultiple{
            if let index = find(Answers, view.tag){
                Answers.removeAtIndex(index)
                view.text = " ☐ " +  Options[view.tag].Title
                //cell!.accessoryType = UITableViewCellAccessoryType.None
            }
            else{
                Answers.append(view.tag)
                view.text = " ☑ " + Options[view.tag].Title
                //cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
        else{
            Answers.removeAll(keepCapacity: false)
            
            Answers.append(view.tag)
            
            for index in 0...Options.count - 1{
                OptionLabels[index].text = " ☐ " + Options[index].Title
            }
            
            view.text = " ☑ " + Options[view.tag].Title
        }
    }
    
    func ViewChart(){
        let chartView = self.storyboard?.instantiateViewControllerWithIdentifier("ChartViewCtrl") as! ChartViewCtrl
        chartView.VoteItems = Options
        
        self.navigationController?.pushViewController(chartView, animated: true)
    }
    
    func Vote(){
        
        if Answers.count > 0{
            
            MustVote = false
            
            if CanMultiple{
                NotificationService.ReplyMultiple(MessageData.Id, accessToken: Global.AccessToken, answers: Answers)
            }
            else{
                NotificationService.ReplySingle(MessageData.Id, accessToken: Global.AccessToken, answerIndex: Answers[0])
            }
            
            MessageData.Voted = true
            MessageCoreData.SaveCatchData(MessageData)
            
            NotificationService.ExecuteNewMessageDelegate()
            
            Global.MyToast.ToastMessage(self.view, callback: { () -> () in
                self.navigationController?.popViewControllerAnimated(true)
            })
            
            //self.navigationController?.popViewControllerAnimated(true)
        }
        else{
            ShowErrorAlert(self, "錯誤", "必須選擇一個以上的選項")
        }
    }
    
    func OpenUrl(){
        let alert = UIAlertController(title: "開啟附加連結", message: "您確定要開啟附加連結？開啟前請先確認該網址的安全性，避免損害您的裝置。", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive){ (action) -> Void in
            
            if let encodeUrl = self.MessageData.Redirect.UrlEncoding{
                let url:NSURL = NSURL(string:encodeUrl)!
                UIApplication.sharedApplication().openURL(url)
            }
            
            })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func UpdateMessage(){
        
        var json = JSON(data: NotificationService.GetMessageById(MessageData.Id, accessToken: Global.AccessToken))
        
        let read = json["progress"]["read"].stringValue
        let total = json["progress"]["total"].stringValue
        
        for receiver in json["to"].arrayValue{
            let uuid = receiver["uuid"].stringValue
            let name = receiver["name"].stringValue
            
            ReadersCatch[uuid] = name
        }
        
        for reader in json["progress"]["readList"].arrayValue{
            ReadList.append(reader.stringValue)
        }
        
        var index = 0
        for selectedOption in json["progress"]["selectedOptions"].arrayValue{
            let count = selectedOption.arrayValue.count
            //兩邊的數量應該一樣,不會發生超出length
            Options[index].Value = count
            index++
        }
        
        //SenderLabel.text = "已讀 ( \(read) / \(total) )"
        
        StatusBtn.setTitle("已讀: \(read)          未讀: \(total.intValue - read.intValue)", forState: UIControlState.Normal)
    }
    
    func GetMessageOptions(){
        
        var json = JSON(data: NotificationService.GetMessageById(MessageData.Id, accessToken: Global.AccessToken))
        
        if let single = json["reply"].number {
            MustVote = false
            Answers.append(single.integerValue)
        }
        else if let multiple = json["reply"].array {
            MustVote = false
            
            for m in multiple{
                Answers.append(m.intValue)
            }
        }
        else{
            MustVote = true
        }
        
        for option in json["options"].arrayValue{
            //Options.append(option.stringValue)
            Options.append(VoteItem(Title: option.stringValue, Value: 0))
        }
    }
    
    func WatchReaderList(){
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("WatchReaderListViewCtrl") as! WatchReaderListViewCtrl
        nextView.ReadersCatch = ReadersCatch
        nextView.ReadList = ReadList
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}

struct VoteItem {
    var Title : String
    var Value : Int
}
