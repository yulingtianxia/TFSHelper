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
    let mainMenu: NSMenu = NSMenu()
    
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
    let recentLinksItem = NSMenuItem()
    let recentLinksMenu = NSMenu()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        recentLinksMenu.delegate = self
        recentLinksItem.title = "常用链接"
        recentLinksMenu.autoenablesItems = false
        recentLinksItem.submenu = recentLinksMenu
        
        mainMenu.delegate = self
        mainMenu.addItem(openLocationItem)
        mainMenu.addItem(recentLinksItem)
        mainMenu.addItem(switchAutoCatchItem)
        mainMenu.addItem(switchAutoLaunchItem)
        mainMenu.addItem(quitItem)
        
        statusItem.button?.image = NSImage(named: "TFSmenu")
        statusItem.menu = mainMenu
        
        recentUseLinks = LRUCache <String, String>()
        let linksData = NSKeyedArchiver.archivedDataWithRootObject(recentUseLinks)
        
        userDefaults.registerDefaults(["autoCatch":autoCatch])
        userDefaults.registerDefaults(["autoLaunch":autoLaunch])
        userDefaults.registerDefaults(["recentUseLinks":linksData])
        
        autoCatch = userDefaults.boolForKey("autoCatch")
        autoLaunch = userDefaults.boolForKey("autoLaunch")
        
        if let data = userDefaults.objectForKey("recentUseLinks") as? NSData {
            recentUseLinks = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! LRUCache <String, String>
        }
        recentUseLinks.countLimit = 5
        
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
        let linksData = NSKeyedArchiver.archivedDataWithRootObject(recentUseLinks)
        userDefaults.setObject(linksData, forKey: "recentUseLinks")
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
    }
    
    func connect(sender: NSStatusBarButton) {
        handlePasteboard()
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
        if menu == mainMenu {
            openLocationItem.hidden = false
            guard let _ = catchTFSLocation() else {
                openLocationItem.hidden = true
                return
            }
        }
        if menu == recentLinksMenu {
            generateLinkItems(menu)
        }
    }
    
    // 生成 MenuItem 数组
    func generateLinkItems(menu: NSMenu) {
        menu.removeAllItems()
        for key in recentUseLinks {
            let item = NSMenuItem(title: recentUseLinks[key]!, action: "handleSelectLink:", keyEquivalent: "")
            menu.addItem(item)
        }
        let clearItem = NSMenuItem(title: "清空列表", action: "clearLinks", keyEquivalent: "")
        if menu.numberOfItems != 0 {
            let separator = NSMenuItem.separatorItem()
            separator.enabled = false
            menu.addItem(separator)
        }
        else {
            clearItem.enabled = false
        }
        menu.addItem(clearItem)
    }
    
    // 处理点击link子菜单事件
    func handleSelectLink(item: NSMenuItem) {
        let index = recentLinksMenu.indexOfItem(item)
        writePasteboard(recentUseLinks[index])
        if !autoCatch {
            handlePasteboard()
        }
    }
    
    // 处理清空 link 菜单事件
    func clearLinks() {
        recentUseLinks.cleanCache()
    }
}
