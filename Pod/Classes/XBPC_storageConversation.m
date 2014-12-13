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

+ (void)addConversation:(NSDictionary *)item
{
    [XBPC_storageConversation addConversation:item save:YES];
}

+ (void)addConversation:(NSDictionary *)item save:(BOOL)save
{
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
    
    if (save)
    {
        [[XBPushChat sharedInstance] saveContext];
    }
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

@end
