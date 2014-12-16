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
@property (nonatomic, retain) NSDate * lastvisit;

+ (void)addConversation:(NSDictionary *)item;
+ (void)addConversation:(NSDictionary *)item save:(BOOL)save;
+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument;
+ (XBPC_storageConversation *)conversationWith:(int)receiver_id andRoom:(NSString *)room;

- (void)visit;
- (NSUInteger)numberOfUnreadMessage;
+ (NSUInteger)numberOfUnreadConversation;

@end
