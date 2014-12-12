//
//  XBPC_storageConversation.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/12/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XBPC_storageConversation : NSManagedObject

@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSNumber * sender;
@property (nonatomic, retain) NSNumber * receiver;
@property (nonatomic, retain) NSString * lastmessage;
@property (nonatomic, retain) NSDate * lasttime;

+ (void)addConversation:(NSDictionary *)item;

@end
