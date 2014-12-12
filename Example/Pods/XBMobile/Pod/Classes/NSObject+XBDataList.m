//
//  NSObject+XBDataList.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 11/11/14.
//
//

#import "NSObject+XBDataList.h"
#import "ASIFormDataRequest.h"
#import "XBExtension.h"

@implementation NSObject (XBDataList)
@dynamic informations;
@dynamic postParams;
@dynamic datalist;
@dynamic isMultipleSection;
@dynamic dataFetching;
@dynamic refreshControl;

#pragma mark - Loading Information

- (void)cleanup
{
    [self loadData:@[]];
    [self loadInformations:@{}];
    [self reloadData];
}

- (void)setPlist:(NSString *)plist
{
    [self loadInformationFromPlist:plist];
}

- (void)setPlistData:(NSString *)plistdata
{
    [self loadData:[NSArray arrayWithContentsOfPlist:plistdata]];
}

- (void)loadInformationFromPlist:(NSString *)plist
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
    [self loadInformations:info];
}

- (void)loadData:(NSArray *)data
{
    if (self.isMultipleSection)
    {
        self.datalist = [data mutableCopy];
    }
    else
    {
        self.datalist = [@[@{@"title": @"root", @"items": data}] mutableCopy];
    }
    [self reloadData];
}

- (void)loadInformations:(NSDictionary *)info
{
    [self loadInformations:info withReload:NO];
}

- (void)loadInformations:(NSDictionary *)info withReload:(BOOL)withReload
{
    [self setupDelegate];
    self.informations = info;
    
    if (info[@"section"])
    {
        self.isMultipleSection = YES;
    }
    
    [self requestDataWithReload:withReload];
    for (NSDictionary *item in self.informations[@"cells"])
    {
        UINib *nib = [UINib loadResourceWithInformation:item];
        [self registerNib:nib forCellReuseIdentifier:item[@"cellIdentify"]];
    }
    
    if ([self.informations[@"isUsingRefreshControl"] boolValue])
    {
        [self initRefreshControl];
    }
    
    if ([self.informations[@"loadMore"][@"enable"] boolValue])
    {
        [self registerNib:[UINib nibWithNibName:self.informations[@"loadMore"][@"xib"] bundle:nil] forCellReuseIdentifier:self.informations[@"loadMore"][@"identify"]];
    }
    
    if ([self respondsToSelector:@selector(setupWaterFall)] && [self.informations[@"waterfall"][@"enable"] boolValue])
    {
        [self setupWaterFall];
    }
}

- (void)initRefreshControl
{
    if (!self.refreshControl)
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(requestData) forControlEvents:UIControlEventValueChanged];
        [(UIView *)self addSubview:self.refreshControl];
    }
}

#pragma mark - Data method & DataFetching Delegate

- (void)requestData
{
    [self requestDataWithReload:NO];
}

- (void)requestDataWithReload:(BOOL)withReload
{
    if ([self.informations[@"isRemoteData"] boolValue])
    {
        if (!self.datalist)
        {
            self.datalist = [NSMutableArray new];
        }
        
        self.dataFetching = [[XBDataFetching alloc] init];
        self.dataFetching.datalist = self.datalist;
        self.dataFetching.info = self.informations;
        self.dataFetching.delegate = self;
        self.dataFetching.postParams = self.postParams;
        [self.dataFetching startFetchingData];
    }
    else
    {
        [self configHeightAfterFillData];
    }
}

- (void)requestDidFinish:(XBDataFetching *)_dataFetching
{
    [self configHeightAfterFillData];
    if ([self.informations[@"isUsingRefreshControl"] boolValue])
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)requestDidFailed:(XBDataFetching *)_dataFetching
{
    if ([self.informations[@"isUsingAlert"] boolValue])
    {
        [self alert:@"Error" message:[self.dataFetching.request.error description]];
    }
    
    if ([self.informations[@"isUsingRefreshControl"] boolValue])
    {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Search

- (void)applySearch:(NSString *)searchKey
{
    if (self.informations[@"searchOptions"])
    {
        if ([self.informations[@"searchOptions"][@"online"] boolValue])
        {
            NSString *searchParams = self.informations[@"searchOptions"][@"searchParam"];
            
            NSMutableDictionary *post = [self.postParams copy];
            post[searchParams] = searchKey;
            
            self.dataFetching = [[XBDataFetching alloc] init];
            self.dataFetching.datalist = self.datalist;
            self.dataFetching.info = self.informations;
            self.dataFetching.delegate = self;
            self.dataFetching.postParams = post;
            [self.dataFetching startFetchingData];
        }
        else
        {
            if (!self.backupWhenSearch)
            {
                self.backupWhenSearch = [self.datalist mutableCopy];
            }
            self.datalist = [self.backupWhenSearch mutableCopy];
            if ([searchKey length] != 0)
            {
                NSMutableString *predicateFormat = [@"" mutableCopy];
                NSMutableArray *args = [@[] mutableCopy];
                for (NSString *field in self.informations[@"searchOptions"][@"fields"])
                {
                    [predicateFormat appendFormat:@"%@ ", field];
                    [predicateFormat appendString:@"CONTAINS %@"];
                    if ([self.informations[@"searchOptions"][@"fields"] indexOfObject:field] != [self.informations[@"searchOptions"][@"fields"] count] - 1)
                    {
                        [predicateFormat appendString:@" OR "];
                    }
                    [args addObject:searchKey];
                }
                
                NSPredicate *pred = [NSPredicate predicateWithFormat:predicateFormat argumentArray:args];
                
                NSMutableArray *result = [@[] mutableCopy];
                for (int i = 0; i < [self.datalist count]; i ++)
                {
                    NSMutableDictionary *item = [self.datalist[i] mutableCopy];
                    NSArray *array = item[@"items"];
                    item[@"items"] = [array filteredArrayUsingPredicate:pred];
                    [result addObject:item];
                }
                self.datalist = [result mutableCopy];
            }
            [self reloadData];
        }
    }
}

- (void)cancelSearch
{
    self.datalist = [self.backupWhenSearch mutableCopy];
}

#pragma mark - Cell generation

- (NSDictionary *)cellInfoForPath:(NSIndexPath *)indexPath
{
    if ([self.informations[@"isMutipleType"] boolValue])
    {
        NSString *path = self.informations[@"cellTypePath"];
        if (!path)
        {
            path = @"cell_type";
        }
        return self.informations[@"cells"][[self.datalist[indexPath.section][@"items"][indexPath.row][path] intValue]];
    }
    return self.informations[@"cells"][0];
}

@end