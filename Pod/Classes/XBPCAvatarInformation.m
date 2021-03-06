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

static XBPCAvatarInformation *__sharedStoreAvatar = nil;

@implementation XBPCAvatarInformation
@synthesize username;

+ (XBPCAvatarInformation *)sharedInstance
{
    if (!__sharedStoreAvatar)
    {
        UIImage *placeHolder = [JSQMessagesAvatarImageFactory circularAvatarImage:[[XBPushChat sharedInstance] avatarPlaceHolder] withDiameter:40];
        __sharedStoreAvatar = [[XBPCAvatarInformation alloc] initWithAvatarImage:nil highlightedImage:nil placeholderImage:placeHolder];
    }
    return __sharedStoreAvatar;
}

+ (XBPCAvatarInformation *)avatarObjectForUsername:(NSString *)username
{
    if ([[XBPushChat sharedInstance] avatarFormat])
    {
        NSString *path = [NSString stringWithFormat:[[XBPushChat sharedInstance] avatarFormat], username];
        UIImage *placeHolder = [JSQMessagesAvatarImageFactory circularAvatarImage:[[XBPushChat sharedInstance] avatarPlaceHolder] withDiameter:40];
        
        if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:path])
        {
            UIImage *img = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:path];
            if (!img)
            {
                img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:path];
            }
            UIImage *avatar = [JSQMessagesAvatarImageFactory circularAvatarImage:img withDiameter:40];
            XBPCAvatarInformation *message = [[XBPCAvatarInformation alloc] initWithAvatarImage:avatar highlightedImage:avatar placeholderImage:placeHolder];
            return message;
        }
        else
        {
            XBPCAvatarInformation *message = [[XBPCAvatarInformation alloc] initWithAvatarImage:nil highlightedImage:nil placeholderImage:placeHolder];
            [[XBPCAvatarInformation sharedInstance] performSelectorOnMainThread:@selector(loadPath:) withObject:path waitUntilDone:YES];
            return message;
        }
    }
    return nil;
}

- (void)loadPath:(NSString *)path
{
    if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:path])
    {
        return;
    }
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:path] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [[SDImageCache sharedImageCache] storeImage:image forKey:path];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XBChatModuleNewAvatar" object:nil];
    }];
}

@end
