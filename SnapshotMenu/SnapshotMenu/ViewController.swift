//
//  ViewController.swift
//  SnapshotMenu
//
//  Created by RowVincent on 2017/1/8.
//  Copyright © 2017年 Nimbosa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let v1:View1 = View1(nibName: "View1", bundle: nil)
        scrollView.addSubview(v1.view)
        self.addChildViewController(v1)
        v1.didMove(toParentViewController: self)
        
        let v2:View2 = View2(nibName: "View2", bundle: nil)
        scrollView.addSubview(v2.view)
        self.addChildViewController(v2)
        v2.didMove(toParentViewController: self)
        
        var V2Frame:CGRect = v2.view.frame
        V2Frame.origin.x = self.view.frame.width
        v2.view.frame = V2Frame
        
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: self.view.frame.width * 2, height: self.view.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }


}

