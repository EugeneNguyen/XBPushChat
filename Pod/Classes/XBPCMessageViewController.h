//
//  XBPCMessageViewController.h
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/6/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "XBPushChat.h"

@interface XBPCMessageViewController : JSQMessagesViewController

@property (nonatomic, assign) NSInteger receiver_id;
@property (nonatomic, assign) NSInteger sender_id;
@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSMutableArray *avatarInformation;
@property (nonatomic, retain) NSString *receiverDisplayName;

@end
