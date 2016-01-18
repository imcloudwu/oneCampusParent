//
//  PhotoPageViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/16/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class PhotoPageViewCtrl: UIViewController,UIScrollViewDelegate
{
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    
    var Base : PreviewData!
    var Index = 0
    
    var TeacherMode = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        scrView.delegate = self
        scrView.maximumZoomScale = 4.0
        scrView.minimumZoomScale = 1.0
        scrView.showsHorizontalScrollIndicator = false
        scrView.showsVerticalScrollIndicator = false
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "LongPress")
        longPress.minimumPressDuration = 0.25
        
        let oneTap = UITapGestureRecognizer(target: self, action: "OneTap")
        oneTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "DoubleTap")
        doubleTap.numberOfTapsRequired = 2
        
        let pinch = UIPinchGestureRecognizer(target: self, action: "iWantPinch:")
        
        view.addGestureRecognizer(longPress)
        view.addGestureRecognizer(oneTap)
        view.addGestureRecognizer(doubleTap)
        view.addGestureRecognizer(pinch)
        
        self.SetTextView(Base.Comment)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            if let img = self.GetDetailImage(){
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.imgView.image = img
                    
                    //PhotoCoreData.UpdateCatchData(self.Base, detail: img)
                })
                
            }
        })
        
        //        if let detail = PhotoCoreData.LoadDetailData(Base){
        //
        //            self.imgView.image = detail
        //        }
        //        else{
        //
        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
        //
        //                if let img = self.GetDetailImage(){
        //
        //                    dispatch_async(dispatch_get_main_queue(), {
        //
        //                        self.imgView.image = img
        //
        //                        //PhotoCoreData.UpdateCatchData(self.Base, detail: img)
        //                    })
        //
        //                }
        //            })
        //        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.commentLabel.hidden = false
    }
    
    func SetTextView(text:String){
        self.commentLabel.hidden = true
        self.commentLabel.text = text
        self.commentLabel.textColor = UIColor.whiteColor()
        self.commentLabel.font = UIFont.systemFontOfSize(16)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView){
        maskView.hidden = scrollView.zoomScale == 1 ? false : true
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?{
        return self.imgView
    }
    
    func GetDetailImage() -> UIImage? {
        
        if let nsd = try? HttpClient.Get(Base.DetailUrl){
            if let img = UIImage(data: nsd){
                
                return img
            }
        }
        
        return nil
    }
    
    func DeletePhoto(){
        
        let con = GetCommonConnect(Base.Dsns)
        
        var err : DSFault!
        
        let rsp = con.SendRequest("photo.DeletePhoto", bodyContent: "<Request><Uid>\(Base.Uid)</Uid></Request>", &err)
        
        Global.MyToast.ToastMessage(self.view, msg: "刪除完成...") { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func SavePhoto(){
        //儲存圖片到本機相簿
        if let img = self.imgView.image{
            UIImageWriteToSavedPhotosAlbum(img, self, nil, nil)
            Global.MyToast.ToastMessage(self.view, msg: "下載完成...",callback : nil)
        }
    }
    
//    func EditPhoto(){
//        
//        let editor = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoEditViewCtrl") as! PhotoEditViewCtrl
//        editor.Base = Base
//        editor.Comment = commentLabel.text
//        
//        self.navigationController?.pushViewController(editor, animated: true)
//    }
    
    func LongPress(){
        
        let menu = UIAlertController(title: "要做什麼呢？", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        menu.addAction(UIAlertAction(title: "下載圖片", style: UIAlertActionStyle.Default, handler: { (ACTION) -> Void in
            self.SavePhoto()
        }))
        
        //老師模式才有的功能
//        if TeacherMode{
//            
//            menu.addAction(UIAlertAction(title: "刪除圖片", style: UIAlertActionStyle.Default, handler: { (ACTION) -> Void in
//                //刪除圖片
//                self.DeletePhoto()
//            }))
//            
//            menu.addAction(UIAlertAction(title: "編輯註解", style: UIAlertActionStyle.Default, handler: { (ACTION) -> Void in
//                //編輯註解
//                self.EditPhoto()
//            }))
//        }
        
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    func OneTap(){
        
        if scrView.zoomScale > 1.0{
            scrView.zoomScale = 1.0
        }
        else{
            self.maskView.hidden = !self.maskView.hidden
        }
        
    }
    
    func DoubleTap(){
        scrView.zoomScale = 4.0
    }
    
    func iWantPinch(sender:UIPinchGestureRecognizer){
        scrView.zoomScale = sender.scale
    }
}
