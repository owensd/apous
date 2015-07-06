     _______
    |   _   .-----.-----.--.--.-----.
    |.  1   |  _  |  _  |  |  |__ --|
    |.  _   |   __|_____|_____|_____|
    |:  |   |__|
    |::.|:. |
    `--- ---'

Apous is a simple tool that allows for easier authoring of Swift scripts.

Primary features:

  1. Allow the breaking up of scripts into multiple files.
  2. Dependency management through [Carthage](https://github.com/Carthage/Carthage) or [CocoaPods](https://github.com/CocoaPods/CocoaPods/).

# How it Works

Apous works by first checking for a `Cartfile` or `Podfile` in your script's directory. If one is
present, then `carthage update` or `pod install --no-integrate` will be run. 

Next, all of your Swift files are combined into a single `.apous.swift` file that can
then be run by the `swift` REPL.

It's really that simple.

# Getting Started

First, you need to install the latest build of Apous.

1. Download the latest version of `apous` from "Releases".
2. Copy it to a location in your path, such as `/usr/local/bin/`.

# Creating Your First Script

1. Create a new directory for your scripts, say `mkdir demo`
2. Change to that directory: `cd demo`
3. Create a new script file: `touch demo.swift`
4. Change the contents of the file to:

```swift
import Foundation

print("Welcome to Apous!")
```

5. Run the script: `apous demo.swift`

This will output: 

    Welcome to Apous!

You can see some other samples here: [Samples](https://github.com/owensd/apous/tree/master/samples).


# Known Issues

Currently there are some design limitations:

  * [Issue #1](https://github.com/owensd/apous/issues/1) - Support for nested directories.  
  * [Issue #2](https://github.com/owensd/apous/issues/2) - Support for folder structure packages.

# FAQ

**Q: What is Apous mean?**

A: It's from the ancient Greek απους, meaning "without feet".
