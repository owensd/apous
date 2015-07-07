//
//  apoustest.swift
//  apoustest
//
//  Created by David Owens on 7/6/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import XCTest

class SamplesTest : XCTestCase {
    
    lazy var samplesPath: String = {
        let path = NSBundle(forClass: self.dynamicType)
            .bundlePath
            .stringByDeletingLastPathComponent
            .stringByAppendingPathComponent("samples") ?? ""
        return path
    }()
    
    func validateSampleToolOutput(sample: String, output: String) {
        do {
            let path: String = samplesPath.stringByAppendingPathComponent(sample)
            if !NSFileManager.defaultManager().fileExistsAtPath(path) {
                XCTFail("The given samples path does not exist: \(path)")
                return
            }
            
            let result = try tools.apous(path)
            XCTAssertEqual(
                result.out.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
                output.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
                "The sample output does not match the expected.")
        }
        catch {
            XCTFail("An error occurred during test execution.")
        }
    }
    
    func testBasic() {
        let output = "Hello! This is a simple sample that contains no dependencies."
        validateSampleToolOutput("basic", output: output)
    }

    func testMulti() {
        let output = "foo: 2\nbar: 1"
        validateSampleToolOutput("multi", output: output)
    }

    func testNested() {
        let output = "Testing Nested Directories\nabspath: abspath!\nbasename: basename!"
        validateSampleToolOutput("nested", output: output)
    }
}
