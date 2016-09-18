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

func unzip(_ destination: String, zipFile: String) {
    let unzip = Process()
    unzip.launchPath = "/usr/bin/unzip"
    unzip.arguments =  ["-uo", "-d", destination, zipFile];
    let pipe = Pipe()
    unzip.standardOutput = pipe
    unzip.launch()
    unzip.waitUntilExit()
}

func writePasteboard(_ location: String) {
    NSPasteboard.general().declareTypes([NSStringPboardType], owner: nil)
    NSPasteboard.general().setString(location, forType: NSStringPboardType)
}

func catchTFSLocation() -> String? {
    if let texts = NSPasteboard.general().readObjects(forClasses: [NSString.self as AnyClass], options: nil) as? [String] {
        for var text in texts {
            if let range = text.range(of: "\\\\tencent") {
                text = convert(text.substring(from: range.lowerBound))
            }
            if let range = text.range(of: "smb://") {
                text = text.substring(from: range.lowerBound)
                return text
            }
        }
    }
    return nil
}

func handlePasteboard() {
    if let result = catchTFSLocation() {
        recentUseLinks[result] = URL(fileURLWithPath: result).pathComponents.last
        writePasteboard(result)
        DistributedNotificationCenter.default().post(name: NSNotification.Name("simulateKeys"), object: Bundle.main.bundleIdentifier!)
    }
    previousChangeCount = NSPasteboard.general().changeCount
}

func convert(_ winConnect: String) -> String {
    return "smb:" + winConnect.replacingOccurrences(of: "tencent\\", with: "tencent.com\\").replacingOccurrences(of: "\\", with: "/").replacingOccurrences(of: "\n", with: "")
}

class CacheGenerator<T:Hashable> : IteratorProtocol {
    
    typealias Element = T
    
    var counter: Int
    let array:[T]
    
    init(keys:[T]) {
        counter = 0
        array = keys
    }
    
    func next() -> Element? {
        let result:Element? = counter < array.count ? array[counter] : nil
        counter += 1
        return result
    }
}

class LRUCache <K:Hashable, V> : NSObject, NSCoding, Sequence {
    
    fileprivate var _cache = [K:V]()
    fileprivate var _keys = [K]()
    
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
                _cache.removeValue(forKey: key)
            }
            else {
                useKey(key)
                _cache[key] = obj
            }
        }
    }
    
    fileprivate func useKey(_ key: K) {
        if let index = _keys.index(of: key) {// key 已存在数组中，只需要将其挪至 index 0
            _keys.insert(_keys.remove(at: index), at: 0)
        }
        else {// key 不存在数组中，需要将其插入 index 0，并在超出缓存大小阈值时移走最后面的元素
            if _keys.count >= countLimit {
                _cache.removeValue(forKey: _keys.last!)
                _keys.removeLast()
            }
            _keys.insert(key, at: 0)
        }
    }
    
    typealias Iterator = CacheGenerator<K>
    
    func makeIterator() -> Iterator {
        return CacheGenerator(keys:_keys)
    }
    
    func cleanCache() {
        _cache.removeAll()
        _keys.removeAll()
    }
    
    // NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        _keys = aDecoder.decodeObject(forKey: "keys") as! [K]
        _cache = aDecoder.decodeObject(forKey: "cache") as! [K:V]
    }
    
    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(_keys as AnyObject as! NSArray, forKey: "keys")
        aCoder.encode(_cache as AnyObject as! NSDictionary, forKey: "cache")
    }
    
}
