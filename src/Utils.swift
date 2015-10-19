//
//  Utils.swift
//  apous
//
//  Created by David Owens on 7/5/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

public extension String {
    public var pathExtension: String { return (self as NSString).pathExtension }
    public var lastPathComponent: String { return (self as NSString).lastPathComponent }
    public var stringByDeletingLastPathComponent: String { return (self as NSString).stringByDeletingLastPathComponent }
    
    public var pathComponents: [String] { return (self as NSString).pathComponents }
    public func stringByAppendingPathComponent(str: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(str)
    }
}

/// Returns the root path that contains the script(s).
func canonicalPath(path: String) throws -> String {
    guard let cpath = path.cStringUsingEncoding(NSUTF8StringEncoding) else { throw ErrorCode.PathNotFound }
    
    let rpath = realpath(cpath, nil)
    if rpath == nil { throw ErrorCode.PathNotFound }
    
    guard let abspath = String(CString: rpath, encoding: NSUTF8StringEncoding) else { throw ErrorCode.PathNotFound }
    return abspath
}

/// Exit the process error with the given `ErrorCode`.
@noreturn func exit(code: ErrorCode) {
    exit(Int32(code.rawValue))
}

/// Returns the full path of the valid script files at the given `path`.
func filesAtPath(path: String) -> [String] {
    let items: [String] = {
        return NSFileManager.defaultManager().subpathsAtPath(path) ?? []
    }()
    
    return items
        .filter() {
            let root = $0.pathComponents[0]
            return $0.pathExtension == "swift" && (root != "Carthage" && root != "Rome" && root != "Pods")
        }
        .map() { path.stringByAppendingPathComponent($0) }
}
