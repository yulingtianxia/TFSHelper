//
//  AppDelegate.swift
//  TFSHelper
//
//  Created by 杨萧玉 on 15/11/26.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let launcherAppIdentifier = "com.yulingtianxia.TFSHelperLauncher"
    let statusItem: NSStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let menu: NSMenu = NSMenu()
    var previousChangeCount: Int = 0
    var autoCatch: Bool = true {
        didSet {
            if autoCatch {
                switchAutoCatchItem.title = "自动连接开启中"
            }
            else {
                switchAutoCatchItem.title = "自动连接已关闭"
            }
        }
    }
    var autoLaunch: Bool = true {
        didSet {
            if autoLaunch {
                switchAutoLaunchItem.title = "登录时启动"
            }
            else {
                switchAutoLaunchItem.title = "登录时不启动"
            }
            SMLoginItemSetEnabled(launcherAppIdentifier, autoLaunch)
        }
    }
    let openLocationItem = NSMenuItem(title: "打开链接", action: "connect:", keyEquivalent: "")
    let quitItem = NSMenuItem(title: "退出", action: "terminate", keyEquivalent: "")
    let switchAutoCatchItem = NSMenuItem(title: "自动连接开启中", action: "switchAutoCatch", keyEquivalent: "")
    let switchAutoLaunchItem = NSMenuItem(title: "登录时启动", action: "switchAutoLaunch", keyEquivalent: "")
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        menu.delegate = self
        menu.addItem(openLocationItem)
        menu.addItem(switchAutoCatchItem)
        menu.addItem(switchAutoLaunchItem)
        menu.addItem(quitItem)
        
        statusItem.button?.image = NSImage(named: "TFSmenu")
        statusItem.menu = menu
        
        userDefaults.registerDefaults(["autoCatch":autoCatch])
        userDefaults.registerDefaults(["autoLaunch":autoLaunch])
        
        autoCatch = userDefaults.boolForKey("autoCatch")
        autoLaunch = userDefaults.boolForKey("autoLaunch")
        
        NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "pollPasteboard:", userInfo: nil, repeats: true)
        
        var startedAtLogin = false
        for app in NSWorkspace.sharedWorkspace().runningApplications {
            if app.bundleIdentifier == launcherAppIdentifier {
                startedAtLogin = true
            }
        }
        
        if startedAtLogin {
            NSDistributedNotificationCenter.defaultCenter().postNotificationName("killme", object: NSBundle.mainBundle().bundleIdentifier!)
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        userDefaults.setBool(autoCatch, forKey: "autoCatch")
        userDefaults.setBool(autoLaunch, forKey: "autoLaunch")
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
        autoCatch = !autoCatch
    }
    
    func switchAutoLaunch() {
        autoLaunch = !autoLaunch
    }
    
    func terminate() {
        NSApp.terminate(nil)
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
