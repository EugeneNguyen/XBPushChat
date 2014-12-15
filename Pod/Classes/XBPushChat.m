//
//  XBPushChat.m
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/5/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import "XBPushChat.h"
#import "ASIFormDataRequest.h"
#import "XBExtension.h"
#import "XBPC_storageMessage.h"

#define XBPC_Service(X) [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/pushchatplus/%@", host, X]]]

typedef enum : NSUInteger {
    eRequestSendMessage = 100,
    eRequestGetHistory,
} XBPCRequestType;

static XBPushChat *__sharedPushChat = nil;

@interface XBPushChat () <ASIHTTPRequestDelegate>

@end

@implementation XBPushChat
@synthesize deviceToken;
@synthesize host, token;
@synthesize avatarFormat, avatarPlaceHolder;

+ (id)sharedInstance
{
    if (!__sharedPushChat)
    {
        __sharedPushChat = [[XBPushChat alloc] init];
    }
    return __sharedPushChat;
}

#pragma mark - Token Management

- (void)registerPush
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)didReceiveToken:(NSData *)_deviceToken
{
    deviceToken = [[[[_deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"%@", deviceToken);
}

- (void)didFailToRegisterForRemoteNotification:(NSError *)error
{
    [self alert:@"Error" message:[error localizedDescription]];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@", userInfo);
    if ([userInfo[@"type"] isEqualToString:@"message"])
    {
        [XBPC_storageMessage addMessage:userInfo];
    }
}

#pragma mark - Percense

- (void)setPresence:(int)presence
{
    [self setPresence:presence synchronous:NO];
}

- (void)setPresence:(int)presence synchronous:(BOOL)synchronous
{
    if (token)
    {
        NSArray *presences = @[@"offline", @"online"];
        ASIFormDataRequest *request = XBPC_Service(@"set_presence");
        [request setValue:self.token forKey:@"token"];
        [request setValue:presences[presence] forKey:@"presence"];
        [request setValue:self.deviceToken forKey:@"device_token"];
        if (synchronous)
        {
            [request startSynchronous];
        }
        else
        {
            [request startAsynchronous];
        }
    }
}

#pragma mark - Send Message

- (void)sendMessage:(NSString *)message toID:(NSUInteger)jid
{
    [self sendMessage:message toID:jid room:@""];
}

- (void)sendMessage:(NSString *)message toID:(NSUInteger)jid room:(NSString *)room
{
    NSString *uuid = [NSString uuidString];
    
    ASIFormDataRequest *request = XBPC_Service(@"send_message");
    [request setPostValue:@(self.sender_id) forKey:@"user_id"];
    [request setPostValue:@(jid) forKey:@"send_to"];
    [request setPostValue:message forKey:@"message"];
    [request setPostValue:uuid forKey:@"random"];
    [request setPostValue:room forKey:@"room"];
    [request setTag:eRequestSendMessage];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [XBPC_storageMessage addMessage:@{@"user_id": @(self.sender_id),
                                      @"send_to": @(jid),
                                      @"random": uuid,
                                      @"message": message,
                                      @"room" : room}];
}

- (void)fetchAllRequest
{
    [self fetchRequestWith:-1];
}

- (void)fetchRequestWith:(NSUInteger)receiver_id
{
    ASIFormDataRequest * request = XBPC_Service(@"get_history");
    [request setPostValue:@(self.sender_id) forKey:@"user_id"];
    if (receiver_id != -1)
    {
        [request setPostValue:@(receiver_id) forKey:@"send_to"];
    }
    [request setDelegate:self];
    [request setTag:eRequestGetHistory];
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *result = request.responseJSON;
    if (!result || [result[@"code"] intValue] != 200)
    {
        return;
    }
    switch (request.tag) {
        case eRequestGetHistory:
        {
            for (NSDictionary *item in result[@"data"])
            {
                [XBPC_storageMessage addMessage:item save:NO];
            }
            [[XBPushChat sharedInstance] saveContext];
        }
            break;
            
        default:
            break;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@", request.error);
}

- (NSInteger)badge
{
    return [[UIApplication sharedApplication] applicationIconBadgeNumber];
}

- (void)setBadge:(NSInteger)badge
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.libreteam._9closets" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"XBPushChat" ofType:@"bundle"]];
    NSURL *modelURL = [bundle URLForResource:@"XBPushChat" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"XBPushChat.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
