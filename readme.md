# Overview

This is the [Payment Highway](https://www.paymenthighway.io) iOS SDK.

## Requirements

* You have an existing iOS project supporting iOS 9 or later
* [Carthage]( https://github.com/Carthage/Carthage) or [CocoaPods](https://cocoapods.org/)
* Valid Payment Highway `account id` and `merchant id`
* Custom-build Mobile Application Backend that returns session id and handles token with token id

## Mobile Application Backend

You will need to have a custom mobile application backend that handles session id and token management.

See the demo project included for a BackendAdapter example.

## License
MIT

# Install

Currently installation via Carthage and CocoaPods is supported.

## Carthage

Create a "Cartfile"-file in the root of your project and add a line within:
```
github "paymenthighway/paymenthighway-ios-framework" "v-2.0.0"
```

Run the following command to integrate the required frameworks to your project.
```
carthage update --platform iOS
```

You can follow the Carthage's instructions for ”[Adding frameworks to an application](https://github.com/Carthage/Carthage)” from step 3 on "If you're building for iOS"

## CocoaPods

You can install CocoaPods with the following commands.

```
$ gem install cocoapods
```

To integrate PaymentHighway framework to your project, specify it in your `Podfile`.
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
    
target '<Your Target Name>' do
    pod 'PaymentHighway', '2.0.0'
end
```

# Use

See the [Demo Project](https://github.com/PaymentHighway/paymenthighway-ios-framework/tree/master/PaymentHighwayDemo) included how to use the framework.
