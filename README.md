# ARNetwork

[![CI Status](http://img.shields.io/travis/dklinzh/ARNetwork.svg?style=flat)](https://travis-ci.org/dklinzh/ARNetwork)
[![Version](https://img.shields.io/cocoapods/v/ARNetwork.svg?style=flat)](http://cocoapods.org/pods/ARNetwork)
[![License](https://img.shields.io/cocoapods/l/ARNetwork.svg?style=flat)](http://cocoapods.org/pods/ARNetwork)
[![Platform](https://img.shields.io/cocoapods/p/ARNetwork.svg?style=flat)](http://cocoapods.org/pods/ARNetwork)

An iOS network framework in combination with HTTP and data cache which based on [AFNetworking](https://github.com/AFNetworking/AFNetworking) and [Realm](https://github.com/realm/realm-cocoa).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* Xcode 8+
* iOS 7+

## Installation

ARNetwork is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ARNetwork', :git => 'https://github.com/dklinzh/ARNetwork.git'

# Add the line below if needs optional module `HTTPDNS`
pod 'ARNetwork/DNS', :git => 'https://github.com/dklinzh/ARNetwork.git'
```

## Author

Daniel Lin, linzhdk@gmail.com

## License

ARNetwork is available under the MIT license. See the LICENSE file for more info.
