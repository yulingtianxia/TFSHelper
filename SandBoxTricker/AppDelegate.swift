//
//  AppDelegate.swift
//  SandBoxTricker
//
//  Created by 杨萧玉 on 16/6/4.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let mainAppIdentifier = "com.yulingtianxia.TFSHelper"

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.simulateKeys), name: "simulateKeys", object: mainAppIdentifier)
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.terminate), name: "killSandBoxTricker", object: mainAppIdentifier)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func simulateKeys() {
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["\(NSBundle.mainBundle().resourcePath!)/simulateKeys.scpt"]
        task.launch()
    }
    
    func terminate() {
        NSApp.terminate(nil)
    }
    
    deinit {
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self)
    }
}

