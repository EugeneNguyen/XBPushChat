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
#import "SDImageCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

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
@dynamic downloaded;

+ (void)addMessage:(NSDictionary *)item
{
    [XBPC_storageMessage addMessage:item save:YES];
}

+ (void)addMessage:(NSDictionary *)item save:(BOOL)save
{
    long deviceSender = [XBPushChat sharedInstance].sender_id;
    long sender = [item[@"user_id"] integerValue];
    long receiver = [item[@"send_to"] integerValue];
    if ((sender == deviceSender && receiver != deviceSender) || (sender != deviceSender && receiver == deviceSender))
    {
        
    }
    else
    {
        return;
    }
    
    XBPC_storageMessage *message = nil;
    NSArray * matched = [XBPC_storageMessage getFormat:@"random=%@" argument:@[item[@"random"]]];
    
    if ([matched count] > 0)
    {
        message = [matched lastObject];
    }
    else
    {
        message  = [NSEntityDescription insertNewObjectForEntityForName:@"XBPC_storageMessage" inManagedObjectContext:[[XBPushChat sharedInstance] managedObjectContext]];
        message.downloaded = @(0);
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
    if ([item[@"message"] rangeOfString:@"New image message"].location == NSNotFound)
    {
        message.message = item[@"message"];
        message.downloaded = @(0);
    }
    else
    {
        message.message = [item[@"message"] substringWithRange:NSMakeRange(19, [item[@"message"] length] - 20)];
        if ([message.downloaded intValue] == 0)
        {
            message.downloaded = @(1);
        }
    }
    
    [XBPC_storageFriendList addUser:@{@"id": message.sender} save:NO];
    [XBPC_storageFriendList addUser:@{@"id": message.receiver} save:NO];
    
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
    NSManagedObjectContext *myContext = [XBPushChat sharedInstance].managedObjectContext;
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"XBPC_storageMessage" inManagedObjectContext:myContext]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * cars = [myContext executeFetchRequest:allCars error:&error];
    
    for (NSManagedObject * car in cars) {
        [myContext deleteObject:car];
    }
    NSError *saveError = nil;
    [myContext save:&saveError];
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

- (NSString *)senderId
{
    return  [self.sender stringValue];
}

- (NSString *)senderDisplayName;
{
    return [self.sender stringValue];
}

- (NSDate *)date
{
    return self.createtime;
}

- (BOOL)isMediaMessage
{
    return [self.downloaded intValue] > 0;
}

- (NSString *)text
{
    if ([self.downloaded intValue] == 0)
    {
        return self.message;
    }
    return nil;
}

- (UIView *)mediaView
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat width = window.frame.size.width * 0.7;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width * 3 / 4)];
    imgView.backgroundColor = [UIColor lightGrayColor];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imgView isOutgoing:[self isOutgoingMessage]];
    if ([self.downloaded intValue] == 0 || [self.message intValue] == -1)
    {
        return nil;
    }
    else
    {
        NSString *path = [NSString stringWithFormat:@"%@/services/user/getInfoPhoto/%d/0", [XBPushChat sharedInstance].host, [self.message intValue]];
        [imgView setImageWithURL:[NSURL URLWithString:path] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        return imgView;
    }
}

- (CGSize)mediaViewDisplaySize
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat width = window.frame.size.width * 0.7;
    return CGSizeMake(width, width * 3 / 4);
}

- (UIView *)mediaPlaceholderView
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat width = window.frame.size.width * 0.7;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width * 3 / 4)];
    imgView.backgroundColor = [UIColor lightGrayColor];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(imgView.frame.size.width / 2 - 15, imgView.frame.size.height / 2 - 15, 30, 30)];
    [imgView addSubview:indicator];
    
    [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imgView isOutgoing:[self isOutgoingMessage]];
    return imgView;
}

- (BOOL)isOutgoingMessage
{
    return [self.sender intValue] == [XBPushChat sharedInstance].sender_id;
}

- (id<JSQMessageMediaData>)media
{
    return self;
}

@end
