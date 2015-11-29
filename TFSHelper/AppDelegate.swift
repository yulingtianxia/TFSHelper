//
//  AppDelegate.swift
//  TFSHelper
//
//  Created by 杨萧玉 on 15/11/26.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    let statusItem: NSStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let menu: NSMenu = NSMenu()
    var previousChangeCount: Int = 0
    var autoCatch: Bool = true
    let openLocationItem = NSMenuItem(title: "打开链接", action: "connect:", keyEquivalent: "")
    let quitItem = NSMenuItem(title: "退出", action: "terminate", keyEquivalent: "")
    let switchAutoCatchItem = NSMenuItem(title: "自动连接开启中", action: "switchAutoCatch", keyEquivalent: "")
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        menu.delegate = self
        menu.addItem(openLocationItem)
        menu.addItem(switchAutoCatchItem)
        menu.addItem(quitItem)
        
        statusItem.button?.image = NSImage(named: "TFSmenu")
        statusItem.menu = menu
        
        NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "pollPasteboard:", userInfo: nil, repeats: true)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return false
    }
    
    func pollPasteboard(timer: NSTimer) {
        if !autoCatch {
            return
        }
        let currentChangeCount = NSPasteboard.generalPasteboard().changeCount
        if currentChangeCount == previousChangeCount {
            return
        }
        handlePasteboard()
        previousChangeCount = NSPasteboard.generalPasteboard().changeCount
    }
    
    func connect(sender: NSStatusBarButton) {
        handlePasteboard()
        previousChangeCount = NSPasteboard.generalPasteboard().changeCount
    }
    
    func switchAutoCatch() {
        if autoCatch {
            autoCatch = false
            switchAutoCatchItem.title = "自动连接已关闭"
        }
        else {
            autoCatch = true
            switchAutoCatchItem.title = "自动连接开启中"
        }
    }
    
    func terminate() {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // MARK: NSMenuDelegate
    
    func menuWillOpen(menu: NSMenu) {
        openLocationItem.hidden = false
        guard let _ = catchTFSLocation() else {
            openLocationItem.hidden = true
            return
        }
    }
}
