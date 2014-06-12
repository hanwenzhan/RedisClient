//
//  ViewController.swift
//  RedisClient
//
//  Created by Christian Lobach on 10.06.14.
//  Copyright (c) 2014 Christian Lobach. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var client = RedisClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
                                    
    }

    @IBAction func pingClicked(sender : AnyObject) {
        client.PING() {(String response) in println(response) }
    }
}

