//
//  XBPCAvatarInformation.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/12/14.
//
//

#import "XBPCAvatarInformation.h"
#import "SDWebImageDownloader.h"
#import "SDWebImageManager.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "XBPushChat.h"

static NSMutableDictionary *__sharedStoreAvatar = nil;

@implementation XBPCAvatarInformation
@synthesize username;

+ (NSMutableDictionary *)sharedStore
{
    if (!__sharedStoreAvatar)
    {
        __sharedStoreAvatar = [@{} mutableCopy];
    }
    return __sharedStoreAvatar;
}

+ (XBPCAvatarInformation *)avatarObjectForUsername:(NSString *)username
{
    if ([[XBPushChat sharedInstance] avatarFormat])
    {
        
        if ([XBPCAvatarInformation sharedStore][username])
        {
            UIImage *avatar = [JSQMessagesAvatarImageFactory circularAvatarImage:[XBPCAvatarInformation sharedStore][username] withDiameter:40];
            XBPCAvatarInformation *message = [[XBPCAvatarInformation alloc] initWithAvatarImage:avatar highlightedImage:avatar placeholderImage:[JSQMessagesAvatarImageFactory circularAvatarImage:[[XBPushChat sharedInstance] avatarPlaceHolder] withDiameter:40]];
            return message;
        }
        else
        {
            XBPCAvatarInformation *message = [[XBPCAvatarInformation alloc] initWithAvatarImage:nil highlightedImage:nil placeholderImage:[JSQMessagesAvatarImageFactory circularAvatarImage:[[XBPushChat sharedInstance] avatarPlaceHolder] withDiameter:40]];
            NSString *path = [NSString stringWithFormat:[[XBPushChat sharedInstance] avatarFormat], username];
            [message loadPath:path];
            message.username = username;
            return message;
        }
    }
    return nil;
}

- (void)loadPath:(NSString *)path
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:path] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [self setAvatarImage:[JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:40]];
        [self setAvatarHighlightedImage:[JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:40]];
        [[XBPCAvatarInformation sharedStore] setValue:[JSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:40] forKey:self.username];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XBChatModuleNewAvatar" object:nil];
    }];
}

@end
