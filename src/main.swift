//
//  main.swift
//  apous
//
//  Created by David Owens on 7/4/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

func printUsage() {
    print("OVERVIEW: Apous Swift Script Runner (build: \(VersionInfo.Version.rawValue)-\(VersionInfo.Branch.rawValue))")
    print("")
    print("USAGE: apous [<script_file>|<path/to/scripts>]")
}


//
// The body of the script.
//

let arguments = NSProcessInfo.processInfo().arguments

if arguments.contains("-help") {
    printUsage()
    exit(0)
}

// This is used to enable more verbose logging.
let DebugOutputEnabled = arguments.contains("-debug")

// NOTE(owensd): This method is a workaround because of Swift bugs and code in the top-level scope.
func run() throws {
    let scriptItem = arguments[1..<arguments.count].filter() { $0 != "-debug" }
    
    let path: String
    switch scriptItem.count {
    case 0:
        path = NSFileManager.defaultManager().currentDirectoryPath
        
    case 1:
        let item = scriptItem[0]
        if item.pathExtension == "swift" {
            if item.lastPathComponent == "main.swift" {
                path = item.stringByDeletingLastPathComponent
            }
            else {
                print("Only a 'main.swift' file can be specified.")
                exit(ErrorCode.InvalidUsage)
            }
        }
        else {
            path = try canonicalPath(item)
        }
        
    default:
        print("Invalid usage.")
        printUsage()
        exit(ErrorCode.InvalidUsage)
    }

    try tools.apous(path)
}

do {
    try run()
}
catch {
    guard let error = error as? ErrorCode else { exit(1) }
    exit(Int32(error.rawValue))
}

