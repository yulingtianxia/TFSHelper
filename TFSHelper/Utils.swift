//
//  Utils.swift
//  TFSConvertor
//
//  Created by 杨萧玉 on 15/11/26.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import Cocoa

func simulateKeys() {
    let task = NSTask()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["\(NSBundle.mainBundle().resourcePath!)/simulateKeys.scpt"]
    task.launch()
}

func writePasteboard(location: String) {
    NSPasteboard.generalPasteboard().declareTypes([NSStringPboardType], owner: nil)
    NSPasteboard.generalPasteboard().setString(location, forType: NSStringPboardType)
}

func handlePasteboard() -> String? {
    if let texts = NSPasteboard.generalPasteboard().readObjectsForClasses([NSString.self as AnyClass], options: nil) as? [String] {
        for text in texts {
            if text.rangeOfString("\\\\tencent") != nil {
                writePasteboard(convert(text))
            }
            else if let range = text.rangeOfString("smb://tencent.com") {
                if range.startIndex == text.startIndex {
                    simulateKeys()
                    return text
                }
            }
        }
    }
    return nil
}

func convert(winConnect: String) -> String {
    if winConnect.rangeOfString("smb://") != nil {
        return winConnect
    }
    return "smb:".stringByAppendingString(winConnect.stringByReplacingOccurrencesOfString("tencent\\", withString: "tencent.com\\").stringByReplacingOccurrencesOfString("\\", withString: "/"))
}