//
//  XBPC_storageMessage.h
//  99closets
//
//  Created by Binh Nguyen Xuan on 12/12/14.
//  Copyright (c) 2014 LIBRETeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XBPC_storageMessage : NSManagedObject

@property (nonatomic, retain) NSString * attach;
@property (nonatomic, retain) NSDate * createtime;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * receiver;
@property (nonatomic, retain) NSNumber * sender;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * random;
@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSNumber * downloaded;

+ (void)addMessage:(NSDictionary *)item;
+ (void)addMessage:(NSDictionary *)item save:(BOOL)save;
+ (NSUInteger)lastIDWithUser:(NSUInteger)user_id;
+ (void)clear;

@end
