//
//  Utils.swift
//  apous
//
//  Created by David Owens on 7/5/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

/// Returns the root path that contains the script(s).
/// This is
func canonicalPath(path: String) throws -> String {
    let path = path.stringByStandardizingPath
    
    var isDirectory: ObjCBool = false
    if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) {
        return path
    }
    
    throw ErrorCode.PathNotFound
}

/// Exit the process error with the given `ErrorCode`.
@noreturn func exit(code: ErrorCode) {
    exit(Int32(code.rawValue))
}

/// Returns the full path of the valid script files at the given `path`.
func filesAtPath(path: String) -> [String] {
    if DebugOutputEnabled {
        print("[debug] Finding script files at path: \(path)")
    }
    
    let items: [String] = {
        return NSFileManager.defaultManager().subpathsAtPath(path) ?? []
    }()
    
    return items
        .filter() { $0 != ".apous.swift" && $0.pathExtension == "swift" }
        .map() { path.stringByAppendingPathComponent($0) }
}


