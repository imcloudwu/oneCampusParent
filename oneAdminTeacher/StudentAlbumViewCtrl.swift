//
//  StudentAlbumViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/21/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentAlbumViewCtrl: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,ContainerViewProtocol{
    
    let CellId = "tagCell"
    
    var StudentData : Student!
    var ParentNavigationItem : UINavigationItem?
    
    var _SectionHeader : AlbumHeader!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var _Datas = [PreviewData]()
    
    var _Albums = [AlbumItem]()
    
    var _SelectAlbum : AlbumItem?
    
    var _AlbumCtrls = [LittleAlbumMenu]()
    
    var _mustReloadHeader = true
    
    var _viewDidAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        _viewDidAppear = true
        
        if _mustReloadHeader{
            ResetAlbums()
            ResetPhotos()
        }
    }
    
    func ResetAlbums(){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let refGroupIds = self.GetMyChildGroupIds()
            
            self._Albums = self.GetAlbums(refGroupIds)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self._mustReloadHeader = true
                self.collectionView.reloadData()
            })
        })
    }
    
    func ResetPhotos(){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            self._Datas = self.GetPhotos()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
        })
    }
    
    func GetMyChildGroupIds() -> String{
        
        var retVal = ""
        
        let rsp = try? HttpClient.Get("https://dsns.1campus.net/\(StudentData.DSNS)/sakura/GetMyChild?stt=PassportAccessToken&AccessToken=\(Global.AccessToken)")
        
        if rsp == nil{
            return retVal
        }
        
        //var nserr : NSError?
        var xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp!)
        } catch _ {
            xml = nil
            return retVal
        }
        
        if let children = xml?.root["Child"].all{
            
            for child in children{
                
                if child["ChildId"].stringValue != StudentData.ID{
                    continue
                }
                
                if let groups = child["Group"].all{
                    
                    for group in groups{
                        
                        let groupId = group["GroupId"].stringValue
                        //let groupName = group["GroupName"].stringValue
                        //let groupOriginal = group["GroupOriginal"].stringValue
                        
                        retVal += "<RefGroupId>" + groupId + "</RefGroupId>"
                    }
                }
            }
        }
        
        return retVal
    }
    
    func GetAlbums(refGroupIds:String) -> [AlbumItem]{
        
        var retVal = [AlbumItem]()
        
        let con = GetCommonConnect(StudentData.DSNS)
        
        var err : DSFault!
        
        let rsp = con.SendRequest("album.GetAlbums", bodyContent: "<Request>\(refGroupIds)</Request>", &err)
        
        if rsp.isEmpty{
            return retVal
        }
        
        let xml = try? AEXMLDocument(xmlData: rsp.dataValue)
        
        if let albums = xml?.root["Response"]["album"].all{
        
            for album in albums{
                
                let uid = album["Uid"].stringValue
                
                let albumName = album["AlbumName"].stringValue
                
                let refGroupId = album["RefGroupId"].stringValue
                
                let photoCount = album["PhotoCount"].stringValue
                
                let previewUrl = album["Preview"].stringValue
                
                var cover : UIImage!
                
                if let imgData = try? HttpClient.Get(previewUrl){
                    if let img = UIImage(data: imgData){
                        cover = img
                    }
                }
                
                if cover == nil{
                    cover = UIImage(named: "default photo.jpg")!
                }
                
                retVal.append(AlbumItem(Cover: cover, School: StudentData.DSNS, Context: albumName, Id: uid, RefGroupId : refGroupId, Count : photoCount))
            }
            
        }
        
        retVal.insert(AlbumItem(Cover: UIImage(named: "Christmas Star Filled-100.png")!, School: "", Context: "被標記的相片", Id: "", RefGroupId: "", Count: ""), atIndex: 0)
        
        return retVal
    }
    
    func GetPhotos() -> [PreviewData]{
        
        var retVal = [PreviewData]()
        
        let con = GetCommonConnect(StudentData.DSNS)
        
        var err : DSFault!
        
        var contract = "photo.GetTagPhotos"
        var body = "<Request><StudentId>\(StudentData.ID)</StudentId></Request>"
        
        if let album = _SelectAlbum{
            contract = "photo.GetAlbumPhotos"
            body = "<Request><RefAlbumId>\(album.Id)</RefAlbumId></Request>"
        }
        
        let rsp = con.SendRequest(contract, bodyContent: body, &err)
        
        if rsp.isEmpty{
            return retVal
        }
        
        let xml = try? AEXMLDocument(xmlData: rsp.dataValue)
        
        if let photots = xml?.root["Response"]["photo"].all{
            
            for photo in photots{
                
                let uid = photo["Uid"].stringValue
                let preview_url = photo["Preview"].stringValue
                let detail_url = photo["Detail"].stringValue
                
                let comment = photo["Comment"].stringValue
                let refGroupId = photo["RefGroupId"].stringValue
                
                let pd = PreviewData(dsns: StudentData.DSNS, refGroupId : refGroupId, uid: uid, previewUrl: preview_url, detailUrl: detail_url)
                pd.Comment = comment
                
                retVal.append(pd)
            }
        }
        
        return retVal
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return _Datas.count
    }
    
    //DidSelectItemAtIndexPath
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoDetailViewCtrl") as! PhotoDetailViewCtrl
        
        nextView.PassValues = _Datas
        nextView.CurrentIndex = indexPath.row
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let data = _Datas[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellId, forIndexPath: indexPath)
        
        let imgView = cell.viewWithTag(100) as! UIImageView
        
        if data.Photo == nil {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                data.UpdatePreviewData()
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if let tempCell = collectionView.cellForItemAtIndexPath(indexPath){
                        
                        let tempImgView = tempCell.viewWithTag(100) as! UIImageView
                        
                        tempImgView.image = data.Photo
                    }
                    
                })
            })
        }
        
        imgView.image = data.Photo
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        switch Global.ScreenSize.width{
        case 414 :
            return CGSizeMake((collectionView.bounds.size.width - 4) / 4, (collectionView.bounds.size.width - 4) / 4)
        case 375 :
            return CGSizeMake((collectionView.bounds.size.width - 3) / 3, (collectionView.bounds.size.width - 3) / 3)
        default :
            return CGSizeMake((collectionView.bounds.size.width - 3) / 3, (collectionView.bounds.size.width - 3) / 3)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        
        if kind == UICollectionElementKindSectionHeader && _mustReloadHeader{
            
            if _viewDidAppear{
                _mustReloadHeader = false
            }
            
            _SectionHeader = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "AlbumHeader", forIndexPath: indexPath) as! AlbumHeader
            
            //_SectionHeader.scrollView.translatesAutoresizingMaskIntoConstraints = true
            
            for ss in _SectionHeader.scrollView.subviews {
                ss.removeFromSuperview()
            }

//            for child in self.childViewControllers{
//                child.removeFromParentViewController()
//            }
            
            var xValue = CGFloat(5)
            
            var index = 0
            
            var newAlbums = [LittleAlbumMenu]()
            
            var firstTap : UITapGestureRecognizer?
            
            for a in _Albums{
                
                let menu = self.storyboard?.instantiateViewControllerWithIdentifier("LittleAlbumMenu") as! LittleAlbumMenu
                
                menu.view.frame = CGRectMake(xValue, 0, 133, 133)
                menu.imv.image = a.Cover
                menu.name.text = a.Context
                menu.view.tag = index
                
                menu.view.layer.shadowColor = UIColor.blackColor().CGColor
                menu.view.layer.shadowOpacity = 0.5
                menu.view.layer.shadowOffset = CGSizeMake(3.0, 2.0)
                menu.view.layer.shadowRadius = 3
                
                let tap = UITapGestureRecognizer(target: self, action: "tapAlbum:")
                menu.view.addGestureRecognizer(tap)
                
                if index == 0{
                    firstTap = tap
                }
                
                _SectionHeader.scrollView.addSubview(menu.view)
                //self.addChildViewController(menu)
                
                xValue += 138
                index++
                
                newAlbums.append(menu)
            }
            
            _AlbumCtrls = newAlbums
            
            _SectionHeader.scrollView.contentSize = CGSizeMake(xValue, 0)
            
            if let sender = firstTap{
                tapAlbum(sender)
            }
            
        }
        
        return _SectionHeader
    }
    
    func tapAlbum(sender:UITapGestureRecognizer){
        
        for ac in _AlbumCtrls{
            ac.contentView.backgroundColor = UIColor.whiteColor()
            //ac.contentView.backgroundColor = UIColor.whiteColor()
        }
        
        if let index = sender.view?.tag{
            
            let ac = _AlbumCtrls[index]
            ac.contentView.backgroundColor = UIColor(red: 181/255.0, green: 187/255.0, blue: 227/255.0, alpha: 1.0)
            
            _SelectAlbum = index == 0 ? nil : _Albums[index]
            ResetPhotos()
        }
    }
}

struct AlbumItem{
    var Cover : UIImage
    var School : String
    var Context : String
    var Id : String
    var RefGroupId : String
    var Count : String
}

class PreviewData{
    
    var Dsns : String
    var RefGroupId : String
    var Uid : String
    var PreviewUrl : String
    var DetailUrl : String
    var Photo : UIImage!
    var Comment : String
    
    init(dsns:String,refGroupId:String,uid:String,previewUrl:String,detailUrl:String){
        Dsns = dsns
        RefGroupId = refGroupId
        Uid = uid
        PreviewUrl = previewUrl
        DetailUrl = detailUrl
        Comment = ""
    }
    
    var Clone : PreviewData{
        
        let pd = PreviewData(dsns: Dsns, refGroupId: RefGroupId, uid: Uid, previewUrl: PreviewUrl, detailUrl: DetailUrl)
        pd.Comment = Comment
        
        return pd
    }
    
    func UpdatePreviewData() -> Bool {
        
        if let nsd = try? HttpClient.Get(PreviewUrl){
            if let img = UIImage(data: nsd){
                
                Photo = img
                
                return true
            }
        }
        
        return false
    }
    
    func GetDeatilImage() -> UIImage? {
        
        if let nsd = try? HttpClient.Get(DetailUrl){
            if let img = UIImage(data: nsd){
                
                return img
            }
        }
        
        return nil
    }
}






