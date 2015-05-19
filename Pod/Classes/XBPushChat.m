
//
//  XBPushChat.m
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/5/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import "XBPushChat.h"
#import "XBMobile.h"
#import "JSONKit.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import <UIImage+ImageCompress.h>
#import "XBGallery.h"

#define XBPC_Service(X) [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/pushchatplus/%@", _host, X]]]
#define XBPC_PushService(X) [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/pushplus/%@", _host, X]]]
#define XBPC_User(X) [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", _host, X]]]

typedef enum : NSUInteger {
    eRequestSendMessage = 100,
    eRequestGetHistory,
    eRequestGetFriendList
} XBPCRequestType;

static XBPushChat *__sharedPushChat = nil;

@interface XBPushChat ()

@end

@implementation XBPushChat
@synthesize deviceToken;
@synthesize host = _host, token;
@synthesize avatarFormat, avatarPlaceHolder;

+ (XBPushChat *)sharedInstance
{
    if (!__sharedPushChat)
    {
        __sharedPushChat = [[XBPushChat alloc] init];
    }
    return __sharedPushChat;
}

- (void)setHost:(NSString *)host
{
    _host = host;
    [[XBGallery sharedInstance] setHost:host];
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
    if (presence == 0)
    {
        [self stopPull];
    }
    else
    {
        [self startPull];
    }
    if (token)
    {
        NSArray *presences = @[@"offline", @"online"];
        XBCacheRequest *request = XBCacheRequest(@"pushchatplus/set_presence");
        request.postParams = [@{@"token": self.token,
                                @"presence": presences[presence],
                                @"device_token": self.deviceToken} mutableCopy];
        request.disableCache = YES;
        request.disableIndicator = YES;
        [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
            
        }];
    }
}

- (void)logout
{
    [self setPresence:0];
    [XBPC_storageMessage clear];
    [XBPC_storageConversation clear];
    self.sender_id = -1;
}

#pragma mark - Send Message

- (void)sendMessage:(NSString *)message toID:(NSUInteger)jid
{
    [self sendMessage:message toID:jid room:@""];
}

- (void)sendMessage:(NSString *)message toID:(NSUInteger)jid room:(NSString *)room
{
    message = [message emojiEncode];
    NSString *uuid = [NSString uuidString];
    
    XBCacheRequest *request = XBCacheRequest(@"pushchatplus/send_message");
    request.disableCache = YES;
    request.disableIndicator = YES;
    request.dataPost = [@{@"user_id": @(self.sender_id),
                          @"send_to": @(jid),
                          @"message": message,
                          @"random": uuid,
                          @"room": room} mutableCopy];
    
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        
    }];
    
    [XBPC_storageMessage addMessage:@{@"user_id": @(self.sender_id),
                                      @"send_to": @(jid),
                                      @"random": uuid,
                                      @"message": message,
                                      @"room" : room}];
}

- (void)sendImage:(UIImage *)image toID:(NSUInteger)jid room:(NSString *)room
{
    NSString *uuid = [NSString uuidString];
    NSString *message = [NSString stringWithFormat:@"Sending image message (%@)", uuid];
    [[SDImageCache sharedImageCache] storeImage:image forKey:uuid];
    
    [XBPC_storageMessage addMessage:@{@"user_id": @(self.sender_id),
                                      @"send_to": @(jid),
                                      @"random": uuid,
                                      @"message": message,
                                      @"room" : room}];
    
    [[XBGallery sharedInstance] uploadImage:image withCompletion:^(NSDictionary *responseData) {
        
        XBCacheRequest *request = XBCacheRequest(@"pushchatplus/send_message");
        request.dataPost = [@{@"user_id": @(self.sender_id),
                              @"send_to": @(jid),
                              @"message": [NSString stringWithFormat:@"New image message (%@)", responseData[@"photo_id"]],
                              @"random": uuid,
                              @"room": room} mutableCopy];
        [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
            
        }];
        
        [XBPC_storageMessage addMessage:@{@"user_id": @(self.sender_id),
                                          @"send_to": @(jid),
                                          @"random": uuid,
                                          @"message": message,
                                          @"room" : room}];
    }];
}

#pragma mark Get History

- (void)fetchAllRequest
{
    [self fetchRequestWith:-1];
}

- (void)fetchRequestWith:(NSUInteger)receiver_id
{
    [self fetchRequestWith:receiver_id newOnly:NO];
}

- (void)fetchRequestWith:(NSUInteger)receiver_id newOnly:(BOOL)newOnly
{
    XBCacheRequest *request = XBCacheRequest(@"pushchatplus/get_history");
    request.disableCache = YES;
    request.disableIndicator = YES;
    request.dataPost[@"user_id"] = @(self.sender_id);
    if (receiver_id != -1)
    {
        request.dataPost[@"send_to"] = @(receiver_id);
    }
    if (newOnly)
    {
        request.dataPost[@"offset"] = @([XBPC_storageMessage lastIDWithUser:receiver_id]);
    }
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        for (NSDictionary *item in object[@"data"])
        {
            [XBPC_storageMessage addMessage:item save:NO];
        }
        [[XBPushChat sharedInstance] saveContext];
        [self getFriendInformationRefresh:NO];
        [self updateHiddenConversation];
    }];
}


- (void)startPull
{
    pulling ++;
    [self pull];
}

- (void)stopPull
{
    pulling --;
    pulling = MAX(pulling, 0);
}

- (void)pull
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (self.sender_id <= 0)
    {
        if (pulling == 1)
        {
            [self performSelector:@selector(pull) withObject:nil afterDelay:5];
        }
        else if (pulling > 1)
        {
            [self stopPull];
        }
        return;
    }
    
    XBCacheRequest *request = XBCacheRequest(@"pushchatplus/get_history");
    request.disableCache = YES;
    request.disableIndicator = YES;
    request.dataPost = [@{@"user_id": @(self.sender_id),
                          @"offset": @([XBPC_storageMessage lastIDWithUser:-1])} mutableCopy];
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *resultString, BOOL fromCache, NSError *error, id result) {
        if (pulling == 1)
        {
            [self performSelector:@selector(pull) withObject:nil afterDelay:5];
        }
        else if (pulling > 1)
        {
            [self stopPull];
        }
        if (!result || [result[@"code"] intValue] != 200 || !result[@"data"])
        {
            return;
        }
        for (NSDictionary *item in result[@"data"])
        {
            [XBPC_storageMessage addMessage:item save:NO];
        }
        [[XBPushChat sharedInstance] saveContext];
        [self getFriendInformationRefresh:NO];
    }];
}

- (void)visit:(XBPC_storageConversation *)conversation
{
    XBCacheRequest *request = XBCacheRequest(@"pushchatplus/mark_as_read");
    request.disableCache = YES;
    request.disableIndicator = YES;
    request.dataPost = [@{@"sender": conversation.sender,
                          @"receiver": conversation.receiver,
                          @"room": conversation.room} mutableCopy];
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        
    }];
}

- (void)hide:(XBPC_storageConversation *)conversation
{
    XBCacheRequest *request = XBCacheRequest(@"pushchatplus/mark_as_read");
    request.disableCache = YES;
    request.disableIndicator = YES;
    request.dataPost = [@{@"sender": conversation.sender,
                          @"receiver": conversation.receiver,
                          @"room": conversation.room} mutableCopy];
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        
    }];
    
    conversation.hidden = @(YES);
    [[XBPushChat sharedInstance] saveContext];
}

- (void)updateHiddenConversation
{
    XBCacheRequest *request = XBCacheRequest(@"pushchatplus/get_hidden_record");
    request.disableCache = YES;
    request.disableIndicator = YES;
    request.dataPost = [@{@"id": @(self.sender_id)} mutableCopy];
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *resultString, BOOL fromCache, NSError *error, id result) {
        NSLog(@"%@", result);
        NSArray *allConversation = [XBPC_storageConversation getAll];
        for (XBPC_storageConversation *conversation in allConversation)
        {
            conversation.hidden = @(NO);
        }
        [[XBPushChat sharedInstance] saveContext];
        if (([result[@"code"] intValue] == 200) && (result[@"data"]))
        {
            for (NSDictionary *item in result[@"data"])
            {
                NSArray *array = [XBPC_storageConversation getFormat:@"sender=%@ and receiver=%@ and room=%@" argument:@[item[@"sender"], item[@"receiver"], item[@"room"]]];
                if ([array count] > 0)
                {
                    XBPC_storageConversation *conversation = [array lastObject];
                    conversation.hidden = @(YES);
                }
            }
        }
        [[XBPushChat sharedInstance] saveContext];
    }];
}

#pragma mark Get Friend's information

- (void)getFriendInformationRefresh:(BOOL)isRefresh
{
    NSArray *friendList = nil;
    if (isRefresh)
    {
        friendList = [XBPC_storageFriendList getAll];
    }
    else
    {
        friendList = [XBPC_storageFriendList getFormat:@"name=nil" argument:@[]];
    }
    
    NSMutableArray *userids = [@[] mutableCopy];
    for (XBPC_storageFriendList *friend in friendList) {
        [userids addObject:friend.id];
        friend.name = @"";
    }
    [[XBPushChat sharedInstance] saveContext];
    
    if ([userids count] == 0)
    {
        return;
    }
    
    XBCacheRequest *request = XBCacheRequest(@"pushchatplus/get_hidden_record");
    request.disableCache = YES;
    request.disableIndicator = YES;
    request.dataPost = [@{@"user_ids": [userids JSONString]} mutableCopy];
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *resultString, BOOL fromCache, NSError *error, id result) {
        for (NSDictionary *item in result[@"data"])
        {
            [XBPC_storageFriendList addUser:@{@"id": item[@"user_id"],
                                              @"name": item[@"username"]}];
        }
    }];
}

- (NSInteger)badge
{
    return [[UIApplication sharedApplication] applicationIconBadgeNumber];
}

- (void)setBadge:(NSInteger)badge
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
}

- (void)updateBadge
{
    NSArray *allConversation = [XBPC_storageConversation getAll];
    int count = 0;
    for (XBPC_storageConversation *conversation in allConversation)
    {
        if (![[conversation hidden] boolValue] && [[conversation numberOfUnreadMessage] intValue] > 0)
        {
            count += [[conversation numberOfUnreadMessage] intValue];
        }
    }
    self.badge = count;
}

- (void)clearBadge
{
    if (self.sender_id > 0)
    {
        XBCacheRequest *request = XBCacheRequest(@"pushplus/clear_badge");
        request.disableCache = YES;
        request.disableIndicator = YES;
        request.dataPost = [@{@"user_id": @(self.sender_id)} mutableCopy];
        [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
            
        }];
    }
    self.badge = 0;
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

