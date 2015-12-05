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

func catchTFSLocation() -> String? {
    if let texts = NSPasteboard.generalPasteboard().readObjectsForClasses([NSString.self as AnyClass], options: nil) as? [String] {
        for var text in texts {
            if let range = text.rangeOfString("\\\\tencent") {
                text = convert(text.substringFromIndex(range.startIndex))
            }
            if let range = text.rangeOfString("smb://tencent.com") {
                text = text.substringFromIndex(range.startIndex)
                return text
            }
        }
    }
    return nil
}

func handlePasteboard() {
    if let result = catchTFSLocation() {
        writePasteboard(result)
        simulateKeys()
        NSPasteboard.generalPasteboard().clearContents()
    }
}

func convert(winConnect: String) -> String {
    return "smb:".stringByAppendingString(winConnect.stringByReplacingOccurrencesOfString("tencent\\", withString: "tencent.com\\").stringByReplacingOccurrencesOfString("\\", withString: "/"))
}