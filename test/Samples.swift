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
        return NSBundle(forClass: self.dynamicType).bundlePath.stringByAppendingPathComponent("samples") ?? ""
    }()
    
//    func testBasic() {
//        let path: String = samplesPath
//        let files: [String] = filesAtPath(path)
//        guard let apous = ApousTool() else { XCTFail("Unable to find the apous tool"); return }
//        apous.run(samplesPath.stringByAppendingPathComponent("basic"))
//    }
    
}
