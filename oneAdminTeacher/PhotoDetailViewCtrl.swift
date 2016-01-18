//
//  PhotoDetailViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class PhotoDetailViewCtrl: UIViewController,UIPageViewControllerDataSource {
    
    var pageViewController : UIPageViewController?
    
    var PassValues : [PreviewData]!
    //var Base : PreviewData!
    var CurrentIndex : Int!
    
    var TeacherMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        
        pageViewController!.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let startingViewController: PhotoPageViewCtrl = viewControllerAtIndex(CurrentIndex)!
        
        let viewControllers = [startingViewController]
        
        pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! PhotoPageViewCtrl).Index
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! PhotoPageViewCtrl).Index
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.PassValues.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> PhotoPageViewCtrl?
    {
        if self.PassValues.count == 0 || index >= self.PassValues.count
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoPageViewCtrl") as! PhotoPageViewCtrl
        
        //        let base = Base.Clone
        //        base.Dsns = PassValues[index].Dsns
        //        base.Uid = PassValues[index].Uid
        
        let base = PassValues[index]
        
        pageContentViewController.Base = base
        pageContentViewController.Index = index
        pageContentViewController.TeacherMode = TeacherMode
        
        CurrentIndex = index
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    
}
