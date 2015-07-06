//
//  Xcode.swift
//  apous
//
//  Created by David Owens on 7/6/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

// <name>.xcodeproj/
//   project.pbxproj
//   project.xcworkspace/
//     contents.xcworkspacedata


import Foundation

func workspaceContents(project: String) -> String {
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Workspace\n   version = \"1.0\">\n   <FileRef\n      location = \"self:\(project).xcodeproj\">\n   </FileRef>\n</Workspace>"
}

func projectFile() -> String {
    return ""
}