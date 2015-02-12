//
//  XBGallery.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 2/4/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^XBGImageUploaded)(NSDictionary * responseData);
typedef void (^XBGImageGetInformation)(NSDictionary * responseData);

@interface XBGallery : NSObject
{
    
}

@property (nonatomic, retain) NSString *host;

+ (XBGallery *)sharedInstance;

- (void)uploadImage:(UIImage *)image withCompletion:(XBGImageUploaded)completeBlock;
- (void)uploadImageURL:(NSString *)url withCompletion:(XBGImageUploaded)completeBlock;

- (NSURL *)urlForID:(int)imageid isThumbnail:(BOOL)isThumbnail;
- (void)infomationForID:(int)imageid withCompletion:(XBGImageGetInformation)completeBlock;

@end