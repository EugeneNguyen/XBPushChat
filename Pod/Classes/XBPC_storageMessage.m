//
//  XBPC_storageMessage.m
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/12/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import "XBPC_storageMessage.h"
#import "XBPC_storageConversation.h"
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
    XBPC_storageMessage *message = nil;
    NSArray * matched;
    if (!item[@"id"])
    {
        matched = [XBPC_storageMessage getFormat:@"random=%@" argument:@[item[@"random"]]];
    }
    else
    {
        matched = [XBPC_storageMessage getFormat:@"id=%@" argument:@[item[@"id"]]];
    }
    
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
                                                @"lasttime": message.createtime}];
    
    [[XBPushChat sharedInstance] saveContext];
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
@end
