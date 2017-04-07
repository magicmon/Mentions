# Mentions

[![Version](https://img.shields.io/cocoapods/v/WCLShineButton.svg?style=flat)](http://cocoapods.org/pods/WCLShineButton)
[![License](https://img.shields.io/cocoapods/l/WCLShineButton.svg?style=flat)](http://cocoapods.org/pods/WCLShineButton)
[![Platform](https://img.shields.io/cocoapods/p/WCLShineButton.svg?style=flat)](http://cocoapods.org/pods/WCLShineButton)
[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/) 
![Language](https://img.shields.io/badge/Language-%20swift%20%20-blue.svg)

An easy way to add mentions in UITextView.

## Demo
![Demo](https://raw.githubusercontent.com/magicmon/Mentions/master/Screenshots/Demo.gif)

## Requirements

* Swift 3.0
* Xcode 8
* iOS 8.0+


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Installation

#### [CocoaPods](http://cocoapods.org) (recommended)

````ruby
use_frameworks!

pod 'Mentions'
````

## Usage

````swift
var mentionTextView = MentionTextView()
view.addSubview(mentionTextView)

// initial text with mention.
mentionTextView.mentionText = "who is your favorite actor or actress? I like [Will Smith] and [Robert Pattinson] the best."

// add to mention.
mentionTextView.insert(to: "Leonardo DiCaprio", with: mentionTextView.selectedRange)
````

If you want to show the text that contains the mention, set it as follows. 

````swift
var textLabel = MentionLabel()
view.addSubview(textLabel)

textLabel.text = mentionTextView.mentionText

// show the mention text.
textLabel.tapHandler = { (mention) in
  let alert = UIAlertView(title: "", message: user, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
  alert.show()
}
````

## Author

magicmon, http://magicmon.tistory.com

## License

**Mentions** is available under the MIT license. See the LICENSE file for more info.
