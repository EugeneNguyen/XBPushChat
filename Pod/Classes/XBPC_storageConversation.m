//
//  XBPC_storageConversation.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/12/14.
//
//

#import "XBPC_storageConversation.h"
#import "XBPushChat.h"

@implementation XBPC_storageConversation

@dynamic room;
@dynamic sender;
@dynamic receiver;
@dynamic lasttime;
@dynamic lastmessage;
@dynamic lastvisit;

+ (void)addConversation:(NSDictionary *)item
{
    [XBPC_storageConversation addConversation:item save:YES];
}

+ (void)addConversation:(NSDictionary *)item save:(BOOL)save
{
    NSMutableDictionary *mutableItem = [item mutableCopy];
    NSNumber *sender = mutableItem[@"sender"];
    
    if ([sender intValue] != [[XBPushChat sharedInstance] sender_id])
    {
        mutableItem[@"receiver"] = mutableItem[@"sender"];
        mutableItem[@"sender"] = @([[XBPushChat sharedInstance] sender_id]);
        item = mutableItem;
    }
    
    XBPC_storageConversation *conversation = nil;
    NSArray * matched = [XBPC_storageConversation getFormat:@"room=%@ and sender=%@ and receiver=%@" argument:@[item[@"room"], item[@"sender"], item[@"receiver"]]];
    if ([matched count] > 0)
    {
        conversation = [matched lastObject];
    }
    else
    {
        conversation = [NSEntityDescription insertNewObjectForEntityForName:@"XBPC_storageConversation" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    }
    conversation.room = item[@"room"];
    conversation.sender = @([item[@"sender"] intValue]);
    conversation.receiver = @([item[@"receiver"] intValue]);
    if (!conversation.lasttime || [conversation.lasttime timeIntervalSinceDate:item[@"lasttime"]] < 0)
    {
        conversation.lasttime = item[@"lasttime"];
        conversation.lastmessage = item[@"lastmessage"];
    }
    
    if (!conversation.lastvisit)
    {
        conversation.lastvisit = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (item[@"lastvisit"])
    {
        conversation.lastvisit = [NSDate date];
    }
    
    if (save)
    {
        [[XBPushChat sharedInstance] saveContext];
    }
}

+ (XBPC_storageConversation *)conversationWith:(int)receiver_id andRoom:(NSString *)room
{
    NSInteger sender = [[XBPushChat sharedInstance] sender_id];
    return [[XBPC_storageConversation getFormat:@"((receiver=%@ and sender=%@) or (receiver=%@ and sender=%@)) and room=%@" argument:@[@(receiver_id), @(sender), @(sender), @(receiver_id), room]] lastObject];
}

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageConversation" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:format argumentArray:argument];
    [fr setPredicate:p1];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"lasttime" ascending:NO];
    [fr setSortDescriptors:@[sd]];
    
    NSArray *result = [[[XBPushChat sharedInstance] managedObjectContext] executeFetchRequest:fr error:nil];
    return result;
}

+ (NSArray *)getAll
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageConversation" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSArray *result = [[[XBPushChat sharedInstance] managedObjectContext] executeFetchRequest:fr error:nil];
    return result;
}

+ (void)clear
{
    NSArray *array = [XBPC_storageConversation getAll];
    for (XBPC_storageConversation *conversation in array)
    {
        [[[XBPushChat sharedInstance] managedObjectContext] deleteObject:conversation];
    }
    [[XBPushChat sharedInstance] saveContext];
}

- (void)visit
{
    self.lastvisit = [NSDate date];
    [[XBPushChat sharedInstance] saveContext];
}

- (NSString *)numberOfUnreadMessage
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageMessage" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"((receiver=%@ and sender=%@) or (receiver=%@ and sender=%@)) and room=%@ and %@<createtime" argumentArray:@[self.sender, self.receiver, self.receiver, self.sender, self.room, self.lastvisit]];
    [fr setPredicate:p1];
    
    return [@([[[XBPushChat sharedInstance] managedObjectContext] countForFetchRequest:fr error:nil]) stringValue];
}

+ (NSUInteger)numberOfUnreadConversation
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageConversation" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"lastvisit<lasttime" argumentArray:@[]];
    [fr setPredicate:p1];
    
    return [[[XBPushChat sharedInstance] managedObjectContext] countForFetchRequest:fr error:nil];
}


- (NSString *)senderUsername
{
    return [XBPC_storageFriendList userById:[self.sender intValue]].name;
}

- (NSString *)receiverUsername
{
    return [XBPC_storageFriendList userById:[self.receiver intValue]].name;
}

@end
