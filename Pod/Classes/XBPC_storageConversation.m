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
@dynamic hidden;

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
    conversation.hidden = @(NO);
    
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
    NSManagedObjectContext *myContext = [XBPushChat sharedInstance].managedObjectContext;
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"XBPC_storageConversation" inManagedObjectContext:myContext]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * cars = [myContext executeFetchRequest:allCars error:&error];
    
    for (NSManagedObject * car in cars) {
        [myContext deleteObject:car];
    }
    NSError *saveError = nil;
    [myContext save:&saveError];
}

- (void)visit
{
    self.lastvisit = [NSDate date];
    NSArray *appliedArray = [XBPC_storageMessage getFormat:@"(receiver=%@ and sender=%@) and room=%@ and read=%@" argument:@[self.sender, self.receiver, self.room, @(NO)]];
    for (XBPC_storageMessage *message in appliedArray)
    {
        message.read = @(YES);
    }
    [[XBPushChat sharedInstance] visit:self];
    [[XBPushChat sharedInstance] saveContext];
}

- (NSString *)numberOfUnreadMessage
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageMessage" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"(receiver=%@ and sender=%@) and room=%@ and read=%@" argumentArray:@[self.sender, self.receiver, self.room, @(NO)]];
    [fr setPredicate:p1];
    
    NSUInteger unread = [[[XBPushChat sharedInstance] managedObjectContext] countForFetchRequest:fr error:nil];
    return [@(unread) stringValue];
}

+ (NSUInteger)numberOfUnreadConversation
{
    NSArray *allConversation = [XBPC_storageConversation getAll];
    int count = 0;
    for (XBPC_storageConversation *conversation in allConversation)
    {
        if (![[conversation hidden] boolValue] && [[conversation numberOfUnreadMessage] intValue] > 0)
        {
            count ++;
        }
    }
    return count;
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
