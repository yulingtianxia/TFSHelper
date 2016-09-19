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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.simulateKeys), name: Notification.Name("simulateKeys"), object: mainAppIdentifier)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.terminate), name: Notification.Name("killSandBoxTricker"), object: mainAppIdentifier)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func simulateKeys() {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["\(Bundle.main.resourcePath!)/simulateKeys.scpt"]
        task.launch()
    }
    
    func terminate() {
        NSApp.terminate(nil)
    }
    
    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }
}

