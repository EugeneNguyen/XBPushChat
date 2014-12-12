//
//  XBPCMessage.h
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/6/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessageData.h"

@interface XBPCMessage : NSObject <JSQMessageData>

@property (nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *senderDisplayName;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) BOOL isMediaMessage;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) id <JSQMessageMediaData> media;
@property (nonatomic, assign) BOOL isOutgoing;

@end
