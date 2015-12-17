//
//  Utils.swift
//  TFSConvertor
//
//  Created by 杨萧玉 on 15/11/26.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

import Cocoa

var recentUseLinks = LRUCache <String, String>()
var previousChangeCount: Int = 0

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
            if let range = text.rangeOfString("smb://") {
                text = text.substringFromIndex(range.startIndex)
                return text
            }
        }
    }
    return nil
}

func handlePasteboard() {
    if let result = catchTFSLocation() {
        recentUseLinks[result] = NSURL(fileURLWithPath: result).pathComponents?.last
        writePasteboard(result)
        simulateKeys()
    }
    previousChangeCount = NSPasteboard.generalPasteboard().changeCount
}

func convert(winConnect: String) -> String {
    return "smb:".stringByAppendingString(winConnect.stringByReplacingOccurrencesOfString("tencent\\", withString: "tencent.com\\").stringByReplacingOccurrencesOfString("\\", withString: "/"))
}

class CacheGenerator<T:Hashable> : GeneratorType {
    
    typealias Element = T
    
    var counter: Int
    let array:[T]
    
    init(keys:[T]) {
        counter = 0
        array = keys
    }
    
    func next() -> Element? {
        return counter < array.count ? array[counter++] : nil
    }
}

class LRUCache <K:Hashable, V> : NSObject, NSCoding, SequenceType {
    
    private var _cache = [K:V]()
    private var _keys = [K]()
    
    var countLimit:Int = 0
    
    override init() {
        
    }
    
    subscript(index:Int) -> K {
        get {
            return _keys[index]
        }
    }
    
    subscript(key:K) -> V? {
        get {
            return _cache[key]
        }
        set(obj) {
            if obj == nil {
                _cache.removeValueForKey(key)
            }
            else {
                useKey(key)
                _cache[key] = obj
            }
        }
    }
    
    private func useKey(key: K) {
        if let index = _keys.indexOf(key) {// key 已存在数组中，只需要将其挪至 index 0
            _keys.insert(_keys.removeAtIndex(index), atIndex: 0)
        }
        else {// key 不存在数组中，需要将其插入 index 0，并在超出缓存大小阈值时移走最后面的元素
            if _keys.count >= countLimit {
                _cache.removeValueForKey(_keys.last!)
                _keys.removeLast()
            }
            _keys.insert(key, atIndex: 0)
        }
    }
    
    typealias Generator = CacheGenerator<K>
    
    func generate() -> Generator {
        return CacheGenerator(keys:_keys)
    }
    
    func cleanCache() {
        _cache.removeAll()
        _keys.removeAll()
    }
    
    // NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        _keys = aDecoder.decodeObjectForKey("keys") as! [K]
        _cache = aDecoder.decodeObjectForKey("cache") as! [K:V]
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_keys as! AnyObject as! NSArray, forKey: "keys")
        aCoder.encodeObject(_cache as! AnyObject as! NSDictionary, forKey: "cache")
    }
    
}