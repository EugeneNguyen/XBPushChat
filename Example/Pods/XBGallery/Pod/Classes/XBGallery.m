//
//  XBGallery.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 2/4/15.
//
//

#import "XBGallery.h"
#import "ASIFormDataRequest.h"
#import "XBMobile.h"

#define service_gallery(X) [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/plusgallery/services/%@", host, X]]]

static XBGallery *__sharedXBGallery = nil;

@implementation XBGallery
@synthesize host;

+ (XBGallery *)sharedInstance
{
    if (!__sharedXBGallery)
    {
        __sharedXBGallery = [[XBGallery alloc] init];
    }
    return __sharedXBGallery;
}

- (void)uploadImage:(UIImage *)image withCompletion:(XBGImageUploaded)completeBlock
{
    ASIFormDataRequest *request = service_gallery(@"addphoto");
    [request addData:UIImageJPEGRepresentation(image, 0.7) withFileName:@"image.jpeg" andContentType:@"image/jpeg" forKey:@"uploadimg"];
    [request startAsynchronous];
    __block ASIFormDataRequest *_request = request;
    [request setCompletionBlock:^{
        completeBlock(_request.responseJSON);
    }];
}

- (void)uploadImageURL:(NSString *)url withCompletion:(XBGImageUploaded)completeBlock
{
    ASIFormDataRequest *request = service_gallery(@"addphoto");
    [request setPostValue:url forKey:@"url"];
    [request startAsynchronous];
    __block ASIFormDataRequest *_request = request;
    [request setCompletionBlock:^{
        completeBlock(_request.responseJSON);
    }];
}

- (NSURL *)urlForID:(int)imageid isThumbnail:(BOOL)isThumbnail
{
    NSString *path = [NSString stringWithFormat:@"%@/plusgallery/services/showbyid/%d/0/%d", self.host, imageid, isThumbnail];
    return [NSURL URLWithString:path];
}

- (void)infomationForID:(int)imageid withCompletion:(XBGImageGetInformation)completeBlock
{
    NSString *path = [NSString stringWithFormat:@"showbyid/%d/1/1", imageid];
    ASIFormDataRequest *request = service_gallery(path);
    [request startAsynchronous];
    __block ASIFormDataRequest *_request = request;
    [request setCompletionBlock:^{
        completeBlock(_request.responseJSON);
    }];
}

@end
