//
//  XBPCAvatarInformation.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/12/14.
//
//

#import "JSQMessagesAvatarImage.h"

@interface XBPCAvatarInformation : JSQMessagesAvatarImage

@property (nonatomic, retain) NSString *username;

+ (XBPCAvatarInformation *)sharedInstance;

+ (XBPCAvatarInformation *)avatarObjectForUsername:(NSString *)username;

- (void)loadPath:(NSString *)path;

@end
