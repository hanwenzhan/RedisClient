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
    
    @IBOutlet var logView : NSScrollView = nil

    var logTextView : NSTextView {
        get {
            return self.logView.contentView.documentView as NSTextView
        }
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
                                    
    }

    @IBAction func pingClicked(sender : AnyObject) {
        client.PING() {(String response) in
            if let text = response {
                self.writeToLog(text)
            } }
    }
    
    func writeToLog(text: String) {
        self.logTextView.insertText(text + "\n")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.logTextView.font = NSFont(name: "Menlo", size: 14.0)
        self.logTextView.textColor = NSColor.greenColor()
    }

}

