     _______
    |   _   .-----.-----.--.--.-----.
    |.  1   |  _  |  _  |  |  |__ --|
    |.  _   |   __|_____|_____|_____|
    |:  |   |__|
    |::.|:. |
    `--- ---'

# Apous [![GitHub license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://raw.githubusercontent.com/owensd/apous/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/owensd/apous.svg)](https://github.com/owensd/Apous/releases)


Apous is a simple tool that allows for easier authoring of Swift scripts.

Primary features:

  1. Allow the breaking up of scripts into multiple files.
  2. Dependency management through [Carthage](https://github.com/Carthage/Carthage) or [CocoaPods](https://github.com/CocoaPods/CocoaPods/).

## How it Works

Apous works by first checking for a `Cartfile` or `Podfile` in your script's directory. If one is
present, then `carthage update` or `pod install --no-integrate` will be run. 

Next, all of your Swift files are compiled into a single `.apousscript` binary that will then be
run automatically for you.

It's really that simple.

## Getting Started

First, you need to install the latest build of Apous.

1. Download the latest version of `apous` from "Releases".
2. Copy it to a location in your path, such as `/usr/local/bin/`.

## Creating Your First Script

1. Create a new directory for your scripts, say `mkdir demo`
2. Change to that directory: `cd demo`
3. Create a new script file: `touch demo.swift`
4. Change the contents of the file to:

    ```swift
    import Foundation

    print("Welcome to Apous!")
    ```

5. Run the script: `apous .`

This will output: 

    Welcome to Apous!

You can see some other samples here: [Samples](https://github.com/owensd/apous/tree/master/samples).

### Alternatively

Apous also supports running scripts with `#!`. Note that your entry point script **must** be named `main.swift`.

```swift
#!/usr/local/bin/apous

import Foundation

print("Welcome to Apous!")
```

Then run:

    > chmod +x main.swift
    > ./main.swift
    Welcome to Apous!


## FAQ

**Q: What is Apous mean?**

A: It's from the ancient Greek απους, meaning "without feet".
