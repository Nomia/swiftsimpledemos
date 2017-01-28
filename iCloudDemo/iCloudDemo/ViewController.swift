//
//  ViewController.swift
//  iCloudDemo
//
//  Created by RowVincent on 2016/12/7.
//  Copyright © 2016年 RowVincent. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    @IBOutlet weak var ownerField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBAction func search(_ sender: AnyObject) {
        let container = CKContainer.default()
        let publicData = container.publicCloudDatabase
        
        let owner     = ownerField.text! as String
        
        let query = CKQuery.init(recordType: "phone", predicate: NSPredicate(format: "(name=%@)", argumentArray: [owner]))
        
        publicData.perform(query, inZoneWith: nil, completionHandler: {records, error in
            
            if error != nil {
                NSLog("查询错误 %@", error!.localizedDescription as String)
            }
            else if records!.count > 0 {
                NSLog("查询到结果")
                let record = records![0] as CKRecord
                
                let phonenum = record.object(forKey: "number") as! String
                
                
                if phonenum != "" {
                    NSLog("输出手机号码 %@", phonenum)
                    
                    DispatchQueue.main.async {
                        self.phoneField!.text = phonenum
                    }
                }
            }
            else {
                NSLog("没有查到结果")
                DispatchQueue.main.async {
                    self.phoneField!.text = ""
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.phoneField.keyboardType = UIKeyboardType.numberPad
        self.ownerField.keyboardType = UIKeyboardType.alphabet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func savePhone(_ sender: AnyObject) {
        let phonenum = self.phoneField!.text
        let name     = self.ownerField!.text
        let pid : NSNumber = NSNumber.init(value: arc4random())
        
        if phonenum == "" || name == "" {
            NSLog("%@", "电话号码，名字不能为空")
            return
        }
        
        NSLog("保存%@的手机号码: %@", name! as String, phonenum! as String)
       
        let container = CKContainer.default()
        let publicData = container.publicCloudDatabase
        
        let record = CKRecord(recordType: "phone")
        record.setValue(phonenum, forKey: "number")
        record.setValue(name, forKey: "name")
        record.setValue(pid, forKey: "pid")
        
        
        publicData.save(record, completionHandler:{_record, error in
            if error != nil {
                NSLog("%@", (error?.localizedDescription)! as String)
            }
            else {
                
                NSLog("%@", _record!.recordID.recordName as String)
            }
        })
        
        self.phoneField!.text = ""
        self.ownerField!.text = ""
        
        self.ownerField.becomeFirstResponder()
    }

}

