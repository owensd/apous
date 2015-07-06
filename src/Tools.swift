//
//  Tools.swift
//  apous
//
//  Created by David Owens on 7/5/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import Foundation

/// The base abstraction for all command-line utilities.
protocol Tool {
    
    /// The name of the tool to be run.
    var launchPath: String { get }
    
    /// Runs the tool and returns result of the execution.
    func run(args: [String]) -> (out: String, err: String, code: Int32)

    /// Runs the tool and returns result of the execution.
    func run(args: String...) -> (out: String, err: String, code: Int32)
}

extension Tool {
    
    /// Runs the tool and returns result of the execution.
    func run(args: String...) -> (out: String, err: String, code: Int32) {
        return run(args)
    }

    /// Provides a default implementation for `run` so that all consumers can make use
    /// of the default behavior of simply running and outputting to `stdout` and `stderr`.
    func run(args: [String]) -> (out: String, err: String, code: Int32) {
        // HACK(owensd): I cannot figure out why this tool will not flush our to stdout in real-time,
        // so forcing it to write to stdout for now.
        let output = NSFileHandle.fileHandleWithStandardOutput()
        let error = NSFileHandle.fileHandleWithStandardError()
        
        var out = ""
        var err = ""
        
        func stream(handle: NSFileHandle) -> String {
            let data = handle.availableData
            let str = NSString(data: data, encoding: NSUTF8StringEncoding) ?? ""
            return str as String
        }
        
        // NOTE(owensd): These don't work for stdout and stderr...
        output.readabilityHandler = { out += stream($0) }
        error.readabilityHandler = { err += stream($0) }
        
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = args
        task.standardOutput = output
        task.standardError = error
        task.terminationHandler = {
            ($0.standardOutput as? NSFileHandle)?.readabilityHandler = nil
            ($0.standardError as? NSFileHandle)?.readabilityHandler = nil
        }
        
        task.launch()
        task.waitUntilExit()
        
        return (
            out: out.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
            err: err.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
            code: task.terminationStatus)
    }
}

struct WhichTool : Tool {
    let launchPath = "/usr/bin/which"

    func run(args: [String]) -> (out: String, err: String, code: Int32) {
        let output = NSPipe()
        let error = NSPipe()
        
        // NOTE(owensd): This merges stdout and stderr for now...
        func stream(handle: NSFileHandle) -> String {
            let data = handle.availableData
            let str = NSString(data: data, encoding: NSUTF8StringEncoding) ?? ""
            
            return str as String
        }
        
        var out = ""
        var err = ""
        
        output.fileHandleForReading.readabilityHandler = { out += stream($0) }
        error.fileHandleForReading.readabilityHandler = { err += stream($0) }
        
        let task = NSTask()
        task.launchPath = self.launchPath
        task.arguments = args
        task.standardOutput = output
        task.standardError = error
        task.terminationHandler = {
            ($0.standardOutput as? NSFileHandle)?.readabilityHandler = nil
            ($0.standardError as? NSFileHandle)?.readabilityHandler = nil
        }
        
        task.launch()
        task.waitUntilExit()
        
        return (
            out: out.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
            err: err.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
            code: task.terminationStatus)
    }
}

struct CocoaPodsTool: Tool {
    let launchPath: String

    init?() {
        guard let path = launchPathForTool("pod") else { return nil }
        self.launchPath = path
    }
}

struct CarthageTool : Tool {
    let launchPath: String

    init?() {
        guard let path = launchPathForTool("carthage") else { return nil }
        self.launchPath = path
    }
}

struct SwiftTool : Tool {
    let launchPath: String
    
    init?() {
        guard let path = launchPathForTool("swiftc") else { return nil }
        self.launchPath = path
    }
}

struct ApousScriptTool : Tool {
    let launchPath = "./.apousscript"
}

func launchPathForTool(tool: String) -> String? {
    let which = WhichTool()
    let result = which.run(tool)
    
    return result.out.characters.count == 0 ? nil : result.out
}
