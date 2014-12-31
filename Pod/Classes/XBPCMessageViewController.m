//
//  XBPCMessageViewController.m
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/6/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import "XBPCMessageViewController.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "JSQMessagesTimestampFormatter.h"
#import "XBPCAvatarInformation.h"
#import "XBPC_storageMessage.h"
#import "XBPC_storageConversation.h"

@interface XBPCMessageViewController () <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    JSQMessagesBubbleImageFactory *bubbleFactory;
}

@property (nonatomic, retain) NSMutableArray *items;

@end

@implementation XBPCMessageViewController
@synthesize receiver_id, sender_id = _sender_id, receiverDisplayName, room;
@synthesize items;

- (void)setSender_id:(NSInteger)sender_id
{
    _sender_id = sender_id;
    [self setSenderId:[@(sender_id) stringValue]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    [self loadDataToTable];
    
    if (self.receiver_id == [[XBPushChat sharedInstance] sender_id])
    {
        self.receiver_id = self.sender_id;
        self.sender_id = [[XBPushChat sharedInstance] sender_id];
    }
    
    self.senderId = [@(self.sender_id) stringValue];
    self.senderDisplayName = self.senderId;
    self.receiverDisplayName = [@(self.receiver_id) stringValue];
    
    [[XBPushChat sharedInstance] fetchRequestWith:self.receiver_id newOnly:YES];
    [[XBPC_storageConversation conversationWith:(int)receiver_id andRoom:room] visit];
    [[XBPushChat sharedInstance] clearBadge];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[XBPC_storageConversation conversationWith:(int)receiver_id andRoom:room] visit];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[XBPushChat sharedInstance] managedObjectContext];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XBPC_storageMessage" inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"createtime" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        NSPredicate *p1 = [NSPredicate predicateWithFormat:@"((receiver=%@ and sender=%@) or (receiver=%@ and sender=%@)) and room=%@" argumentArray:@[@(self.receiver_id), @(self.sender_id), @(self.sender_id), @(self.receiver_id), self.room]];
        [fetchRequest setPredicate:p1];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            NSLog(@"Error performing fetch: %@", error);
        }
    }
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self loadDataToTable];
}

- (void)loadDataToTable
{
    if (!items)
    {
        items = [@[] mutableCopy];
    }
    [items removeAllObjects];
    for (int sectionIndex = 0; sectionIndex < [[[self fetchedResultsController] sections] count]; sectionIndex ++)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:sectionIndex];
        for (int i = 0; i < [sectionInfo numberOfObjects]; i ++)
        {
            XBPC_storageMessage *item = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
            [items addObject:item];
        }
    }
    [self finishReceivingMessage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [[XBPushChat sharedInstance] sendMessage:text toID:[@(self.receiver_id) intValue] room:self.room];
    [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Attach photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a photo", @"Select from gallery", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet firstOtherButtonIndex])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (buttonIndex == [actionSheet firstOtherButtonIndex] + 1)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image)
    {
        image = info[UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [[XBPushChat sharedInstance] sendImage:image toID:self.receiver_id room:self.room];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return items[indexPath.row];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XBPC_storageMessage *message = items[indexPath.row];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:224.0f/255.0f green:245.0f/255.0f blue:252.0f/255.0f alpha:1]];
    }
    
    return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:181.0f/255.0f green:231.0f/255.0f blue:250.0f/255.0f alpha:1]];
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XBPC_storageMessage *message = items[indexPath.row];
    XBPCAvatarInformation *avatar = [XBPCAvatarInformation avatarObjectForUsername:message.senderId];
    return avatar;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        XBPC_storageMessage *message = items[indexPath.row];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    XBPC_storageMessage *lastItem = items[indexPath.row];
    XBPC_storageMessage *nearByItem = items[indexPath.row - 1];
    
    if ([lastItem.createtime timeIntervalSinceDate:nearByItem.createtime] > 300)
    {
        XBPC_storageMessage *message = items[indexPath.row];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}
#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [items count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    XBPC_storageMessage *msg = items[indexPath.row];
    
    if (! msg.isMediaMessage) {
        
        cell.textView.textColor = [UIColor blackColor];
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    XBPC_storageMessage *lastItem = items[indexPath.row];
    XBPC_storageMessage *nearByItem = items[indexPath.row - 1];
    
    if ([lastItem.createtime timeIntervalSinceDate:nearByItem.createtime] > 300)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end
