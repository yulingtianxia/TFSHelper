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
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        let running = NSWorkspace.sharedWorkspace().runningApplications
        var alreadyRunning = false
        
        for app in running {
            if app.bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                break
            }
        }
        
        if !alreadyRunning {
            NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.terminate), name: "killLauncher", object: mainAppIdentifier)
            
            let path = NSBundle.mainBundle().bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("TFSHelper") //main app name
            
            let newPath = NSString.pathWithComponents(components)
            
            NSWorkspace.sharedWorkspace().launchApplication(newPath)
        }
        else {
            self.terminate()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func terminate() {
        NSApp.terminate(nil)
    }
    
    deinit {
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self)
    }
}

