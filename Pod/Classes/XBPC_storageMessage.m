//
//  XBPC_storageMessage.m
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/12/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import "XBPC_storageMessage.h"
#import "XBPushChat.h"
#import "XBExtension.h"

@implementation XBPC_storageMessage

@dynamic attach;
@dynamic createtime;
@dynamic id;
@dynamic message;
@dynamic receiver;
@dynamic sender;
@dynamic type;
@dynamic random;
@dynamic room;

+ (void)addMessage:(NSDictionary *)item
{
    [XBPC_storageMessage addMessage:item save:YES];
}

+ (void)addMessage:(NSDictionary *)item save:(BOOL)save
{
    XBPC_storageMessage *message = nil;
    NSArray * matched = [XBPC_storageMessage getFormat:@"random=%@" argument:@[item[@"random"]]];
    
    if ([matched count] > 0)
    {
        message = [matched lastObject];
    }
    else
    {
        message  = [NSEntityDescription insertNewObjectForEntityForName:@"XBPC_storageMessage" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    }
    
    message.id = @([item[@"id"] intValue]);
    message.sender = @([item[@"user_id"] intValue]);
    message.receiver = @([item[@"send_to"] intValue]);
    message.random = item[@"random"];
    if (item[@"createtime"])
    {
        message.createtime = [item[@"createtime"] mysqlDate];
    }
    else
    {
        message.createtime = [NSDate date];
    }
    message.type = @"message";
    message.room = item[@"room"];
    message.message = item[@"message"];
    
    [XBPC_storageConversation addConversation:@{@"sender": message.sender,
                                                @"receiver": message.receiver,
                                                @"room": message.room,
                                                @"lastmessage": message.message,
                                                @"lasttime": message.createtime} save:save];
    if (save)
    {
        [[XBPushChat sharedInstance] saveContext];
    }
}

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageMessage" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:format argumentArray:argument];
    [fr setPredicate:p1];
    
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"createtime" ascending:YES];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    
    [fr setSortDescriptors:@[sd1, sd2]];
    
    NSArray *result = [[[XBPushChat sharedInstance] managedObjectContext] executeFetchRequest:fr error:nil];
    return result;
}

+ (NSArray *)getAll
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageMessage" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSArray *result = [[[XBPushChat sharedInstance] managedObjectContext] executeFetchRequest:fr error:nil];
    return result;
}

+ (void)clear
{
    NSArray *array = [XBPC_storageMessage getAll];
    for (XBPC_storageMessage *message in array)
    {
        [[[XBPushChat sharedInstance] managedObjectContext] deleteObject:message];
    }
    [[XBPushChat sharedInstance] saveContext];
}

+ (NSUInteger)lastIDWithUser:(NSUInteger)user_id
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageMessage" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    if (user_id != -1)
    {
        NSPredicate *p1 = [NSPredicate predicateWithFormat:@"sender=%@ or receiver=%@" argumentArray:@[@(user_id), @(user_id)]];
        [fr setPredicate:p1];
    }
    
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    [fr setSortDescriptors:@[sd2]];
    [fr setFetchLimit:1];
    
    NSArray *result = [[[XBPushChat sharedInstance] managedObjectContext] executeFetchRequest:fr error:nil];
    XBPC_storageMessage *lastMessage = [result lastObject];
    return [lastMessage.id integerValue];
}

@end
