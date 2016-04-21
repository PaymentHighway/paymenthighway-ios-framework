# Overview

Clutch is the name for the Solinor Payment Highway iOS SDK (actually it is a .framework).

## Requirements

* At least Xcode 7.3
* You have an existing iOS project supporting iOS 8 or later
* [Carthage]( https://github.com/Carthage/Carthage)
* Valid SPH account id and merchant id
* Custom-build Mobile Application Backend that returns session id and handles token with token id 

## Mobile Application Backend

You will need to have a custom mobile application backend that handles session id and token management. Clutch framework includes helper methods for an application backend that will return values as JSON. See helperGetTransactionId and helperGetToken in Networking-class.

## License
MIT

## Todo

* CocoaPods release
* Manual installation instructions
* iOS SDK should validate that the received certificate is signed by Certificate Authority (CA should be bundled with SDK)
* Remove IQKeyboardManager and do a custom solution.
* Remove SwiftyJson
* Separate Demo-project from the Clutch project


# Install

Currently only Carthage is supported. CocoaPods release is planned and manual installation needs instructions.

## Carthage

1. Create a "Cartfile"-file in the root of your project and add a line within: 
```
github "solinor/paymenthighway-ios-framework" "v-1.0.1" 
```

2. Run command
```
carthage update --platform iOS
```

3. Follow the Carthage's instructions for ”[Adding frameworks to an application](https://github.com/Carthage/Carthage)” from steap 3 on "If you're building for iOS"

# Use

See the demo project included how to use Clutch.

In short, you need to import clutch, initialize framework (for instance in AppDelegate) and call presentSPHAddCardViewController when you want to show SPH dialog.

# Problems

## carthage update fails

If you receive

```
Code Sign error: No code signing identities found: No valid signing identities (i.e. certificate and private key pair) matching the team ID “(null)” were found.
CodeSign error: code signing is required for product type 'Framework' in SDK 'iOS 8.4'
```

then make sure you have iOS distribution license installed (Xcode->Preferences->Accounts->View Details->Signing Identities).
