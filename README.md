# XBPushChat

[![CI Status](http://img.shields.io/travis/eugenenguyen/XBPushChat.svg?style=flat)](https://travis-ci.org/eugenenguyen/XBPushChat)
[![Version](https://img.shields.io/cocoapods/v/XBPushChat.svg?style=flat)](http://cocoadocs.org/docsets/XBPushChat)
[![License](https://img.shields.io/cocoapods/l/XBPushChat.svg?style=flat)](http://cocoadocs.org/docsets/XBPushChat)
[![Platform](https://img.shields.io/cocoapods/p/XBPushChat.svg?style=flat)](http://cocoadocs.org/docsets/XBPushChat)
[![PayPayl donate button](http://img.shields.io/paypal/donate.png?color=yellow)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Y22J3LQZCAN2A "Donate once-off to this project using Paypal")

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

XBPushChat is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "XBPushChat"

## How to use

1. Install XBPushChat & PushChat + (a module of PlusIgniter)
2. Config XBPushChat when app start:

```objc
[[XBPushChat sharedInstance] registerPush]; // register push notification, support all iOS
[[XBPushChat sharedInstance] setHost:@"http://ciplustest.libre.com.vn"]; // setup host of PushChat+
```

and some bootstrap 

```objc
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[XBPushChat sharedInstance] setPresence:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[XBPushChat sharedInstance] setPresence:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[XBPushChat sharedInstance] setPresence:1];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[XBPushChat sharedInstance] setPresence:1];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[XBPushChat sharedInstance] setPresence:0 synchronous:YES];
}

#pragma mark - Push Delegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[XBPushChat sharedInstance] didReceiveToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[XBPushChat sharedInstance] didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[XBPushChat sharedInstance] didFailToRegisterForRemoteNotification:error];
}
```

3. After get your userid (after login / register), you can start to chat:

```objc
[[XBPushChat sharedInstance] setSender_id:99]; // 99 is your userid
```objc

4. Fetch your history
```objc
[[XBPushChat sharedInstance] fetchAllRequest]; //get all history
//or 
[[XBPushChat sharedInstance] fetchRequestWith:100]; //get all message between you and user 100
```

5. Setup your presence
```objc
[[XBPushChat sharedInstance] setPresence:1]; //1 is online. 0 is offline
```

6. And show the chat view anytime you need
```objc

```

## Author

eugenenguyen, xuanbinh91@gmail.com

## Contact

Any question, request, suggest, please feel free to send to us. You're always welcome.

[LIBRETeamStudio](https://twitter.com/LIBRETeamStudio)

## License

XBMobile is available under the MIT license. See the LICENSE file for more info.

## Donation

This is open-source project. If you want to support us to keep develop this, or just give me a beer, don't be shy :) i will always appreciate that.

[![PayPayl donate button](http://img.shields.io/paypal/donate.png?color=yellow)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Y22J3LQZCAN2A "Donate once-off to this project using Paypal")

## License

XBPushChat is available under the MIT license. See the LICENSE file for more info.
