//
//  AppDelegate.swift
//  TFSHelperLauncher
//
//  Created by 杨萧玉 on 15/11/29.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let mainAppIdentifier = "com.yulingtianxia.TFSHelper"
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let running = NSWorkspace.shared().runningApplications
        var alreadyRunning = false
        
        for app in running {
            if app.bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                break
            }
        }
        
        if !alreadyRunning {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.terminate), name: NSNotification.Name("killLauncher"), object: mainAppIdentifier)
            
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("TFSHelper") //main app name
            
            let newPath = NSString.path(withComponents: components)
            
            NSWorkspace.shared().launchApplication(newPath)
        }
        else {
            self.terminate()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func terminate() {
        NSApp.terminate(nil)
    }
    
    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }
}

