//
//  ViewController.swift
//  SocketDemo
//
//  Created by RowVincent on 2016/12/13.
//  Copyright © 2016年 RowVincent. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBAction func emitEvent(_ sender: AnyObject) {
        socket.emit("test", 100, 200)
    }
    let socket = SocketIOClient(socketURL: URL(string: "http://192.168.31.172:8080")!, config: [.log(true), .forcePolling(true)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        socket.on("testclient", callback: {data, ack in
            if let x = data[0] as? Int, let y = data[1] as? Int {
                print("get x: \(x) get y: \(y)")
            }
        })
        
        socket.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                self.socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                    self.socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }
        
        socket.connect()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

