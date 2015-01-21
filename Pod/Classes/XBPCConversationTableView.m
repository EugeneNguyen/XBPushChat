//
//  XBPCConversationTableView.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/12/14.
//
//

#import "XBPCConversationTableView.h"
#import "XBExtension.h"
#import "XBPushChat.h"
#import "XBPC_storageConversation.h"

@interface XBPCConversationTableView () <NSFetchedResultsControllerDelegate, XBTableViewDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    NSMutableArray *conversation;
}
@property (nonatomic, retain) NSFetchedResultsController *friendListFetchedResult;

@end

@implementation XBPCConversationTableView
@synthesize friendListFetchedResult;

- (void)awakeFromNib
{
    [self loadInformations:[NSDictionary dictionaryWithContentsOfPlist:@"XBPCConversationTableViewConfig" bundleName:@"XBPushChat"]];
    [self loadDataToTable];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self loadDataToTable];
}

- (void)loadDataToTable
{
    conversation = [@[] mutableCopy];
    for (int sectionIndex = 0; sectionIndex < [[[self fetchedResultsController] sections] count]; sectionIndex ++)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:sectionIndex];
        for (int i = 0; i < [sectionInfo numberOfObjects]; i ++)
        {
            XBPC_storageConversation *item = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
            if (![item isHide])
            {
                [conversation addObject:item];
            }
        }
    }
    [self loadData:conversation];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[XBPushChat sharedInstance] managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XBPC_storageConversation" inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"lasttime" ascending:NO];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            NSLog(@"Error performing fetch: %@", error);
        }
        
        
        friendListFetchedResult = [XBPC_storageFriendList fetchedResult];
        friendListFetchedResult.delegate = self;
        
    }
    return fetchedResultsController;
}

@end
