//
//  XBGallery.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 2/4/15.
//
//

#import "XBGallery.h"
#import "XBCacheRequest.h"

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

- (XBCacheRequest *)uploadImage:(UIImage *)image withCompletion:(XBGImageUploaded)completeBlock
{
    NSString *url = [NSString stringWithFormat:@"%@/plusgallery/services/addphoto", host];
    XBCacheRequest *request = XBCacheRequest(url);
    [request addFileWithData:UIImageJPEGRepresentation([[image fixOrientation] resized], 0.7) key:@"uploadimg" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    request.disableCache = YES;
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        completeBlock(object, [object[@"photo_id"] intValue]);
    }];
    return request;
}

- (XBCacheRequest *)uploadImageURL:(NSString *)url withCompletion:(XBGImageUploaded)completeBlock
{
    NSString *urlRequest = [NSString stringWithFormat:@"%@/plusgallery/services/addphoto", host];
    XBCacheRequest *request = XBCacheRequest(urlRequest);
    [request setDataPost:[@{@"url": url} mutableCopy]];
    request.disableCache = YES;
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        completeBlock(object, [object[@"photo_id"] intValue]);
    }];
    return request;
}

- (XBCacheRequest *)uploadImages:(NSArray *)images withCompletion:(XBGMultipleImageUploaded)completeBlock
{
    NSMutableArray *arrayImage = [@[] mutableCopy];
    for (UIImage *img in images)
    {
        [arrayImage addObject:[@{@"image": img} mutableCopy]];
    }
    [self uploadImageOneByOne:arrayImage withComplete:completeBlock];
}

- (void)uploadImageOneByOne:(NSMutableArray *)arrayImage withComplete:(XBGMultipleImageUploaded)completeBlock
{
    BOOL found = NO;
    for (NSMutableDictionary *information in arrayImage)
    {
        if (information[@"id"])
        {
            continue;
        }
        else
        {
            [self uploadImage:information[@"image"] withCompletion:^(NSDictionary *responseData, int photoid) {
                information[@"id"] = @(photoid);
                [self uploadImageOneByOne:arrayImage withComplete:completeBlock];
            }];
            found = YES;
            break;
        }
    }
    if (!found)
    {
        completeBlock([arrayImage valueForKey:@"id"]);
    }
}

- (NSURL *)urlForID:(int)imageid isThumbnail:(BOOL)isThumbnail
{
    NSString *path = [NSString stringWithFormat:@"%@/plusgallery/services/showbyid?id=%d&origin=%d", self.host, imageid, !isThumbnail];
    return [NSURL URLWithString:path];
}

- (NSURL *)urlForID:(int)imageid size:(CGSize)size
{
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    NSString *path = [NSString stringWithFormat:@"%@/plusgallery/services/showbyid?id=%d&width=%f&height=%f", self.host, imageid, size.width * screenScale, size.height * screenScale];
    return [NSURL URLWithString:path];
}

- (void)infomationForID:(int)imageid withCompletion:(XBGImageGetInformation)completeBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/plusgallery/services/showbyid/%d/1/1", host, imageid];
    XBCacheRequest *request = XBCacheRequest(path);
    request.disableCache = YES;
    [request startAsynchronousWithCallback:^(XBCacheRequest *request, NSString *result, BOOL fromCache, NSError *error, id object) {
        completeBlock(object);
    }];
}

@end
