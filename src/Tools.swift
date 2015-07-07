//
//  Tools.swift
//  apous
//
//  Created by David Owens on 7/5/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

// I'm playing around with using functions as the types here because that's all
// that is really needed. The types with a protocol extension in the previous
// version just felt like way too much for what was really needed, which is
// essentially just a way to invoke the tool with some arguments.

/// The output type for a `Tool`.
typealias TaskResult = (out: String,code: Int32)

/// The function signature that all tools must conform to.
typealias Tool = (args: String...) throws -> TaskResult

/// Runs the given tool at `launchPath` passing in `args`. The output is then captured
/// by `output` and `error`.
func runTask(launchPath: String, args: [String] = [], outputToStandardOut: Bool = true) throws -> TaskResult
{
    // This is the buffered output that will be returned.
    var out = ""

// It turns out this code is not robust; it does not seem to always get all of the stream data.
// BUG #12 - https://github.com/owensd/apous/issues/12
//
//    // Ok, so stdout sucks the big one. If your NSTask actually does any redirection to another
//    // tool that then outputs to stdout, that is going to be buffered and will only come back in
//    // chunks.
//    
//    var master: Int32 = 0
//    var slave: Int32 = 0
//    if openpty(&master, &slave, nil, nil, nil) == -1 {
//        throw ErrorCode.PTYCreationFailed
//    }
//    defer {
//        close(master)
//        close(slave)
//    }
//
//    let output = NSFileHandle(fileDescriptor: master)

    func stream(handle: NSFileHandle) -> String {
        let data = handle.availableData
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as? String ?? ""

        // Sample string might look like this: ^[[34;1m***^[[0m Fetching ^[[1mArgo^[[0m
        // However, we need the escape codes to look like this: \e[34;1m***\e[0m Fetching \e[1mArgo\e[0m
        // Also, the normal output logged needs to have all of that stripped...
        
        func process(input: String, fn: (inout string: String, range: Range<String.Index>) -> ()) -> String {
            var str = input
            
            var range: Range<String.Index>? = nil
            var nextRange: Range<String.Index>? = nil
            repeat {
                range = str.rangeOfString(
                    "(\\^)\\[\\[(\\d+;\\d+m|\\d+m)",
                    options: NSStringCompareOptions.RegularExpressionSearch,
                    range: nextRange)
                
                if let range = range {
                    nextRange?.startIndex = range.endIndex
                    fn(string: &str, range: range)
                }
            } while range != nil
            
            return str
        }
        
        let replaced = process(str) { (inout string: String, range: Range<String.Index>) in
            string.replaceRange(range.startIndex ..< advance(range.startIndex, 2), with: "\\e")
        }
        
        let stripped = process(str) { (inout string: String, range: Range<String.Index>) in
            string.removeRange(range)
        }
        
        if outputToStandardOut {
            // NOTE(owensd): Without the -n, additional newlines are getting in there...
            NSTask.launchedTaskWithLaunchPath("/bin/bash", arguments: ["-c", "echo -en $'\(replaced)'"])
        }
        
        return stripped
    }

    let output = NSPipe()
    
    output.fileHandleForReading.readabilityHandler = { out += stream($0) }
    
    let task = NSTask()
    task.launchPath = try canonicalPath(launchPath)
    task.arguments = args
    task.standardOutput = output
    task.standardError = output
    task.terminationHandler = {
        ($0.standardOutput as? NSFileHandle)?.readabilityHandler = nil
    }
    
    task.launch()
    task.waitUntilExit()
    
    return (
        out: out.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
        code: task.terminationStatus)
}

// This is my pseudo-namespace thing that I'm trying out for now...
struct tools {
    private init() { fatalError("Can't you see, this is a namespace!") }
}

private func launchPathForTool(tool: String) throws -> String? {
    let result = try tools.which(tool)
    return result.out.characters.count == 0 ? nil : result.out
}

extension tools {
    static func which(args: String...) throws -> TaskResult {
        return try runTask("/usr/bin/which", args: args, outputToStandardOut: false)
    }
    
    static func pod(args: String...) throws -> TaskResult {
        guard let path = try launchPathForTool("pod") else { throw ErrorCode.CocoaPodsNotInstalled }

        let info = args.reduce("") { $0 + $1 + " " }
        print("Running pod \(info)")
        return try runTask(path, args: args)
    }
    
    static func carthage(args: String...) throws -> TaskResult {
        guard let path = try launchPathForTool("carthage") else { throw ErrorCode.CarthageNotInstalled }
        
        let info = args.reduce("") { $0 + $1 + " " }
        print("Running carthage \(info)")
        return try runTask(path, args: args)
    }

    static func swiftc(args: [String]) throws -> TaskResult {
        guard let path = try launchPathForTool("swiftc") else { throw ErrorCode.SwiftNotInstalled }
        return try runTask(path, args: args)
    }

    static func swiftc(args: String...) throws -> TaskResult {
        return try tools.swiftc(args)
    }
}

extension tools {
    static let CartfileConfig = "Cartfile"
    static let PodfileConfig = "Podfile"

    static func apous(path: String) throws -> TaskResult {
        let fileManager = NSFileManager.defaultManager()
        
        // The tools need to be run under the context of the script directory.
        fileManager.changeCurrentDirectoryPath(path)
        
        var frameworkPaths: [String] = []
        
        if fileManager.fileExistsAtPath(path.stringByAppendingPathComponent(CartfileConfig)) {
            try tools.carthage("update")
            frameworkPaths += ["-F", "Carthage/Build/Mac"]
        }
        
        if fileManager.fileExistsAtPath(path.stringByAppendingPathComponent(PodfileConfig)) {
            try tools.pod("install", "--no-integrate")
            frameworkPaths += ["-F", "Rome"]
        }
        
        let files = filesAtPath(path)
        let args = frameworkPaths + ["-o", ".apousscript"] + files
        
        try tools.swiftc(args)
        return try runTask("./.apousscript")
    }
}

