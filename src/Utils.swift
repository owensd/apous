//
//  Utils.swift
//  apous
//
//  Created by David Owens on 7/5/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

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
        .filter() { $0.pathExtension == "swift" }
        .map() { path.stringByAppendingPathComponent($0) }
}


