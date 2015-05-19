//
//  NSObject+XBGallery.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 4/15/15.
//
//

#import "NSObject+XBGallery.h"
#import "SDWebImageDownloader.h"

@implementation NSObject (XBGallery)

- (void)loadImageFromURL:(NSURL *)url callBack:(SEL)selector
{
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
        if ([self respondsToSelector:selector])
        {
            [self performSelectorOnMainThread:selector withObject:newImage waitUntilDone:YES];
        }
    }];
}

@end
