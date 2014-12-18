//
//  XBPC_storageFriendList.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/17/14.
//
//

#import "XBPC_storageFriendList.h"
#import "XBPushChat.h"


@implementation XBPC_storageFriendList

@dynamic id;
@dynamic name;
@dynamic presence;

+ (void)addUser:(NSDictionary *)item
{
    [XBPC_storageFriendList addUser:item save:YES];
}

+ (void)addUser:(NSDictionary *)item save:(BOOL)save
{
    XBPC_storageFriendList *friend = nil;
    NSArray * matched = [XBPC_storageFriendList getFormat:@"id=%@" argument:@[item[@"id"]]];
    
    if ([matched count] > 0)
    {
        friend = [matched lastObject];
    }
    else
    {
        friend  = [NSEntityDescription insertNewObjectForEntityForName:@"XBPC_storageFriendList" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    }
    
    friend.id = @([item[@"id"] intValue]);
    if (item[@"name"])
    {
        friend.name = item[@"name"];
    }
    friend.presence = @([item[@"presence"] intValue]);
    if (save)
    {
        [[XBPushChat sharedInstance] saveContext];
    }
}

+ (XBPC_storageFriendList *)userById:(int)uid
{
    return [[XBPC_storageFriendList getFormat:@"id=%@" argument:@[@(uid)]] lastObject];
}

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageFriendList" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:format argumentArray:argument];
    [fr setPredicate:p1];
    
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    
    [fr setSortDescriptors:@[sd2]];
    
    NSArray *result = [[[XBPushChat sharedInstance] managedObjectContext] executeFetchRequest:fr error:nil];
    return result;
}

+ (NSArray *)getAll
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageFriendList" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSArray *result = [[[XBPushChat sharedInstance] managedObjectContext] executeFetchRequest:fr error:nil];
    return result;
}

+ (NSFetchedResultsController *)fetchedResult
{
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"XBPC_storageFriendList" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    [fr setSortDescriptors:@[sd2]];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fr managedObjectContext:[[XBPushChat sharedInstance] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    [controller performFetch:nil];
    return controller;
}

+ (void)clear
{
    NSArray *array = [XBPC_storageFriendList getAll];
    for (XBPC_storageFriendList *friend in array)
    {
        [[[XBPushChat sharedInstance] managedObjectContext] deleteObject:friend];
    }
    [[XBPushChat sharedInstance] saveContext];
}

@end
