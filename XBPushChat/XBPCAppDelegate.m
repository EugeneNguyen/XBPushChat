//
//  XBPCAppDelegate.m
//  XBPushChat
//
//  Created by CocoaPods on 12/05/2014.
//  Copyright (c) 2014 eugenenguyen. All rights reserved.
//

#import "XBPCAppDelegate.h"
#import <XBPushChat.h>
#import "XBPCViewController.h"

@implementation XBPCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    XBPCViewController *viewController= [[XBPCViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.window setRootViewController:navi];
    [self.window makeKeyAndVisible];
    
    [[XBPushChat sharedInstance] registerPush];
    [[XBPushChat sharedInstance] setHost:@"http://ciplustest.libre.com.vn"];
    [[XBPushChat sharedInstance] setSender_id:99];
    [[XBPushChat sharedInstance] fetchAllRequest];
    [[XBPushChat sharedInstance] setPresence:1];
    return YES;
}
							
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

@end
