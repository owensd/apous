//
//  ErrorCodes.swift
//  apous
//
//  Created by David Owens on 7/5/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

enum ErrorCode: Int, ErrorType {
    case InvalidUsage = 1
    case PathNotFound
    case CarthageNotInstalled
    case CocoaPodsNotInstalled
    case SwiftNotInstalled
    case PTYCreationFailed
}
