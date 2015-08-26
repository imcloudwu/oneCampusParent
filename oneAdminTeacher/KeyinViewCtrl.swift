//
//  KeyinViewCtrl.swift
//  oneCampusParent
//
//  Created by Cloud on 8/25/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class KeyinViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UITextFieldDelegate,UIWebViewDelegate {
    
    var _DSNSDic:[String:String]!
    var _display:[String]!
    
    var _isBusy = false
    
    var _lastCount = -1
    
    @IBOutlet weak var autoView: UITableView!
    @IBOutlet weak var server: UITextField!
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var relationship: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var webView : UIWebView!
    var _DsnsItem : DsnsItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitBtn.layer.masksToBounds = true
        submitBtn.layer.cornerRadius = 5
        
        webView = UIWebView()
        webView.hidden = true
        webView.delegate = self
        
        _DSNSDic = [String:String]()
        _display = [String]()
        
        autoView.delegate = self
        autoView.dataSource = self
        
        server.delegate = self
        code.delegate = self
        relationship.delegate = self
        
        server.addTarget(self, action: "GetServerName", forControlEvents: UIControlEvents.EditingChanged)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.webView.frame = self.view.bounds
        self.view.addSubview(self.webView)
    }
    
    func GetServerName(){
        
        let count = self.server.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        if _lastCount != count && !_isBusy{
            _lastCount = count
            newSearch(self.server.text)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.view.endEditing(true)
        
        if autoView.hidden == false{
            autoView.hidden = true
        }
        
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        if autoView.hidden == false{
            autoView.hidden = true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _display.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "auto")
        cell.textLabel?.text = _display[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        autoView.hidden = true
        server.text = _display[indexPath.row]
    }
    
    func newSearch(matchName:String){
        
        _isBusy = true
        
        //encode成功呼叫查詢
        if let encodingName = matchName.UrlEncoding{
            
            HttpClient.Get("http://dsns.1campus.net/campusman.ischool.com.tw/config.public/GetSchoolList?content=%3CRequest%3E%3CMatch%3E\(encodingName)%3C/Match%3E%3CPagination%3E%3CPageSize%3E10%3C/PageSize%3E%3CStartPage%3E1%3C/StartPage%3E%3C/Pagination%3E%3C/Request%3E", successCallback: { (response) -> Void in
                
                if !response.isEmpty {
                    
                    //println(NSString(data: rsp, encoding: NSUTF8StringEncoding))
                    
                    var tmpDic = [String:String]()
                    
                    var nserr : NSError?
                    
                    let xml = AEXMLDocument(xmlData: response.dataValue, error: &nserr)
                    
                    if let schools = xml?.root["Response"]["School"].all{
                        
                        for school in schools{
                            let name = school["Title"].stringValue
                            let dsns = school["DSNS"].stringValue
                            
                            tmpDic[name] = dsns
                        }
                    }
                    
                    self._DSNSDic = tmpDic
                    self._display = tmpDic.keys.array
                    
                    if self._display.count > 0{
                        self.autoView.reloadData()
                        self.autoView.hidden = false
                    }
                    else{
                        self.autoView.hidden = true
                    }
                }

                self._isBusy = false
                
            }, errorCallback: { (error) -> Void in
                
                self._isBusy = false
            }, prepareCallback: { (request) -> Void in
                //code
            })
        }
    }
    
    @IBAction func submit(sender: AnyObject) {
        
        var serverName = ""
        
        if let dsns = _DSNSDic[server.text]{
            serverName = dsns
        }
        else{
            serverName = server.text
        }
        
        AddApplicationRef(serverName)
    }
    
    func AddApplicationRef(server:String){
        
        self._DsnsItem = DsnsItem(name: "", accessPoint: server)
        
        if !contains(Global.DsnsList,self._DsnsItem){
            
            var err : DSFault!
            var con = Connection()
            con.connect("https://auth.ischool.com.tw:8443/dsa/greening", "user", SecurityToken.createOAuthToken(Global.AccessToken), &err)
            
            if err != nil{
                ShowErrorAlert(self, "過程發生錯誤", err.message)
                return
            }
            
            var rsp = con.sendRequest("AddApplicationRef", bodyContent: "<Request><Applications><Application><AccessPoint>\(server)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>", &err)
            
            if err != nil{
                ShowErrorAlert(self, "過程發生錯誤", err.message)
                return
            }
            
            Global.DsnsList.append(self._DsnsItem)
            
            ShowWebView()
        }
        else{
            JoinAsParent()
        }
    }
    
    func ShowWebView(){
        
        let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(Global.clientID)&response_type=token&redirect_uri=http://_blank&scope=User.Mail,User.BasicInfo,1Campus.Notification.Read,1Campus.Notification.Send,*:auth.guest,*:1campus.mobile.parent&access_token=\(Global.AccessToken)"
        
        var urlobj = NSURL(string: target)
        var request = NSURLRequest(URL: urlobj!)
        
        self.webView.loadRequest(request)
        self.webView.hidden = false
    }
    
    func JoinAsParent(){
        
        let relationShip = self.relationship.text.isEmpty ? "iOS Parent" : self.relationship.text
        
        var err : DSFault!
        var con = Connection()
        con.connect(_DsnsItem.AccessPoint, "auth.guest", SecurityToken.createOAuthToken(Global.AccessToken), &err)
        
        if err != nil{
            ShowErrorAlert(self, "過程發生錯誤", err.message)
            return
        }
        
        var rsp = con.sendRequest("Join.AsParent", bodyContent: "<Request><ParentCode>\(code.text)</ParentCode><Relationship>\(relationShip)</Relationship></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self, "過程發生錯誤", err.message)
            return
        }
        
        var nserr : NSError?
        let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let success = xml?.root["Body"]["Success"]{
            
            let alert = UIAlertController(title: "加入成功", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                Global.NeedRefreshChildList = true
                
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else{
            ShowErrorAlert(self, "加入失敗", "發生不明的錯誤,請回報給開發人員")
        }
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
        
        //網路異常
        if error.code == -1009 || error.code == -1003{
            
            if UpdateTokenFromError(error){
                JoinAsParent()
            }
            else{
                ShowErrorAlert(self, "連線過程發生錯誤", "若此情況重複發生,建議重登後再嘗試")
            }
        }
    }
    
    func UpdateTokenFromError(error: NSError) -> Bool{
        
        var accessToken : String!
        var refreshToken : String!
        
        if let url = error.userInfo?["NSErrorFailingURLStringKey"] as? String{
            
            let stringArray = url.componentsSeparatedByString("&")
            
            if stringArray.count != 5{
                return false
            }
            
            if let range1 = stringArray[0].rangeOfString("http://_blank/#access_token="){
                accessToken = stringArray[0]
                accessToken.removeRange(range1)
            }
            
            if let range2 = stringArray[4].rangeOfString("refresh_token="){
                refreshToken = stringArray[4]
                refreshToken.removeRange(range2)
            }
        }
        
        if accessToken != nil && refreshToken != nil{
            Global.SetAccessTokenAndRefreshToken((accessToken: accessToken, refreshToken: refreshToken))
            return true
        }
        
        return false
    }
}