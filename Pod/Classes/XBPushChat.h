//
//  XBPushChat.h
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/5/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "XBPC_storageMessage.h"
#import "XBPC_storageConversation.h"
#import "XBPC_storageFriendList.h"

#import "XBPCConversationTableView.h"

#import "XBPCAvatarInformation.h"
#import "XBPCMessageViewController.h"

@interface XBPushChat : NSObject
{
    int pulling;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) NSInteger badge;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, assign) NSUInteger sender_id;
@property (nonatomic, retain) NSString * avatarFormat;
@property (nonatomic, retain) UIImage * avatarPlaceHolder;

+ (XBPushChat *)sharedInstance;
- (void)registerPush;

- (void)didReceiveToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotification:(NSError *)error;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)setPresence:(int)presence;
- (void)setPresence:(int)presence synchronous:(BOOL)synchronous;

- (void)startPull;
- (void)stopPull;

- (void)sendMessage:(NSString *)message toID:(NSUInteger)jid;
- (void)sendMessage:(NSString *)message toID:(NSUInteger)jid room:(NSString *)room;
- (void)sendImage:(UIImage *)image toID:(NSUInteger)jid room:(NSString *)room;

- (void)fetchAllRequest;
- (void)fetchRequestWith:(NSUInteger)receiver_id;
- (void)fetchRequestWith:(NSUInteger)receiver_id newOnly:(BOOL)newOnly;

- (void)visit:(XBPC_storageConversation *)conversation;
- (void)hide:(XBPC_storageConversation *)conversation;

- (void)getFriendInformationRefresh:(BOOL)isRefresh;

- (void)updateBadge;
- (void)logout;

@end