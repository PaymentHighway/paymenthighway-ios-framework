# Overview

This is the Solinor Payment Highway (SPH) iOS SDK.

## Requirements

* At least Xcode 7.3
* You have an existing iOS project supporting iOS 8 or later
* [Carthage]( https://github.com/Carthage/Carthage) or [CocoaPods](https://cocoapods.org/)
* Valid SPH account id and merchant id
* Custom-build Mobile Application Backend that returns session id and handles token with token id

## Mobile Application Backend

You will need to have a custom mobile application backend that handles session id and token management. Clutch framework includes helper methods for an application backend that will return values as JSON. See helperGetTransactionId and helperGetToken in Networking-class.

## License
MIT

## Todo

* Manual installation instructions
* iOS SDK should validate that the received certificate is signed by Certificate Authority (CA should be bundled with SDK)
* Remove IQKeyboardManager and do a custom solution.
* Support landscape orientation
* ~~Remove SwiftyJson~~
* ~~CocoaPods Release~~

# Install

Currently installation via Carthage and CocoaPods is supported.

## Carthage

Create a "Cartfile"-file in the root of your project and add a line within:
```
github "solinor/paymenthighway-ios-framework" "v-1.0.5"
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
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'PaymentHighway', '1.0.5'
end
```

# Use

See the demo project included how to use the framework.

In short, you need to import PaymentHighway, initialize the framework (for instance in `AppDelegate`, check the demo) and present `SPHAddCardViewController` when you want to show SPH dialog.

# Problems

## Carthage update fails

If you see the following error during framework installation using Carthage

```
Code Sign error: No code signing identities found: No valid signing identities (i.e. certificate and private key pair) matching the team ID “(null)” were found.
CodeSign error: code signing is required for product type 'Framework' in SDK 'iOS 8.4'
```

then make sure you have iOS distribution license installed (Xcode->Preferences->Accounts->View Details->Signing Identities).
