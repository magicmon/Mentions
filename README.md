# Mentions
<p>
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
   <a href="http://cocoapods.org/pods/Mentions">
      <img src="https://img.shields.io/cocoapods/v/Mentions.svg?style=flat" alt="Version">
   </a>
   <a href="http://cocoapods.org/pods/Mentions">
      <img src="https://img.shields.io/cocoapods/p/Mentions.svg?style=flat" alt="Platform">
   </a>
   <a href="http://cocoapods.org/pods/Mentions">
      <img src="https://img.shields.io/cocoapods/l/Mentions.svg?style=flat" alt="License">
   </a>
</p>

An easy way to add mentions in UITextView.

## Demo
![Demo](https://raw.githubusercontent.com/magicmon/Mentions/master/Screenshots/Demo.gif)

## Requirements

* Swift 5.0
* Xcode 11
* iOS 10.0+


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

// or Add the text of the mention inside special characters "[]".
textLabel.text = "[Brad Pitt]"


// show the mention text.
textLabel.tapHandler = { (mention) in
  let alert = UIAlertView(title: "", message: mention, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
  alert.show()
}
````

## Author

magicmon, http://magicmon.github.io

## License

**Mentions** is available under the MIT license. See the LICENSE file for more info.
