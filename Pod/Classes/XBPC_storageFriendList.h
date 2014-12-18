//
//  XBPC_storageFriendList.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 12/17/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XBPC_storageFriendList : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * presence;

+ (void)addUser:(NSDictionary *)item;
+ (void)addUser:(NSDictionary *)item save:(BOOL)save;
+ (XBPC_storageFriendList *)userById:(int)uid;

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument;
+ (NSArray *)getAll;

+ (NSFetchedResultsController *)fetchedResult;

@end
