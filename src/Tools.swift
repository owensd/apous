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
    
    /// `true` when the output of the tool should be printed to `stdout`.
    var printOutput: Bool { get }
    
    /// Runs the tool and returns result of the execution.
    func run(args: String...) -> (out: String, err: String, code: Int32)
}

extension Tool {
    var printOutput: Bool { return true }

    func run(args: String...) -> (out: String, err: String, code: Int32) {
        let output = NSPipe()
        let error = NSPipe()
        
        // NOTE(owensd): This merges stdout and stderr for now...
        func stream(handle: NSFileHandle) -> String {
            let data = handle.availableData
            let str = NSString(data: data, encoding: NSUTF8StringEncoding) ?? ""
            
            if self.printOutput {
                print("\(str)", appendNewline: false)
            }
            
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


struct WhichTool : Tool {
    let printOutput = false
    let launchPath = "/usr/bin/which"
}

struct CarthageTool : Tool {
    let launchPath: String
    
    init?() {
        let which = WhichTool()
        let result = which.run("carthage")
        if result.out.characters.count == 0 { return nil }
        self.launchPath = result.out
    }
    
    // HACK(owensd): I cannot figure out why this tool will not flush our to stdout in real-time,
    // so forcing it to write to stdout for now.
    func run(args: String...) -> (out: String, err: String, code: Int32) {
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

struct SwiftTool : Tool {
    let launchPath: String
    
    init?() {
        let which = WhichTool()
        let result = which.run("swift")
        if result.out.characters.count == 0 { return nil }
        self.launchPath = result.out
    }
}
