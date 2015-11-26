//
//  AppDelegate.swift
//  TFSHelper
//
//  Created by 杨萧玉 on 15/11/26.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem: NSStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var previousChangeCount: Int = 0
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        statusItem.button?.image = NSImage(named: "TFSmenu")
        statusItem.button?.action = Selector("menuClicked:")
        statusItem.button?.target = self
        
        NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "pollPasteboard:", userInfo: nil, repeats: true)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func menuClicked(sender: NSStatusBarButton) {
        handlePasteboard()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return false
    }
    
    func pollPasteboard(timer: NSTimer) {
        let currentChangeCount = NSPasteboard.generalPasteboard().changeCount
        if currentChangeCount == previousChangeCount{
            return
        }
        handlePasteboard()
        previousChangeCount = currentChangeCount
    }
}
