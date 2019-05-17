//
//  HLSDownloader.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloader.h"
#import "HLSDownloader+Private.h"
#import "HLSDownloader+LocalServer.h"

#import <UIKit/UIApplication.h>
#import <YYModel.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

static dispatch_queue_t hls_downloader_queue(){
    static dispatch_queue_t hls_downloader_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hls_downloader_queue = dispatch_queue_create("com.alex.HLSDownloader", DISPATCH_QUEUE_SERIAL);
    });
    return hls_downloader_queue;
}

@interface HLSDownloader ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, HLSDownloadItem *> *itemDic;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation HLSDownloader
+ (HLSDownloader *)shareDownloader;
{
    static HLSDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[HLSDownloader alloc] init];
    });
    return downloader;
}

- (void)setAllowCellular:(BOOL)allowCellular
{
    _allowCellular = allowCellular;
    
    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN] && allowCellular == NO){
        [self pauseAllDownload];
    }
}

- (void)setMaxTaskCount:(NSUInteger)maxTaskCount
{
    _maxTaskCount = maxTaskCount;
    
    self.operationQueue.maxConcurrentOperationCount = maxTaskCount;
}

- (void)setEnableSpeed:(BOOL)enableSpeed
{
    _enableSpeed = enableSpeed;
    
    dispatch_async(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HLSDownloadItem *item, BOOL *stop) {
            item.enableSpeed = enableSpeed;
        }];
    });
}

- (void)startDownload:(HLSDownloadItem *)item;
{
    dispatch_async(hls_downloader_queue(), ^{
        // exist same item
        if ([self.itemDic objectForKey:item.uniqueId]) {
            return;
        }
        
        item.enableSpeed = self.enableSpeed;
        [self.itemDic setObject:item forKey:item.uniqueId];
        
        [item start];
    });
}

- (void)startDownloadWith:(NSString *)url uniqueId:(NSString *)unique priority:(float)priority;
{
    HLSDownloadItem *item = [[HLSDownloadItem alloc] initWithUrl:url uniqueId:unique priority:0];
    item.opQueue = self.operationQueue;
    item.fileContainer = self.fileContainer;
    [self startDownload:item];
}

- (void)pauseDownload:(HLSDownloadItem *)item;
{
    [item pause];
}

- (void)stopDownload:(HLSDownloadItem *)item;
{
    [item stop];
    
    dispatch_async(hls_downloader_queue(), ^{
        [self.itemDic removeObjectForKey:item.uniqueId];
    });
}

- (void)stopDownloads:(NSArray <HLSDownloadItem *> *)items
{
    [items enumerateObjectsUsingBlock:^(HLSDownloadItem *obj, NSUInteger idx, BOOL *stop) {
        [self stopDownload:obj];
    }];
}

- (void)startAllDownload;
{
    dispatch_async(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HLSDownloadItem *obj, BOOL *stop) {
            if (obj.status != HLSDownloadItemStatusDownloading) {
                [obj start];
            }
        }];
    });
}

- (void)pauseAllDownload;
{
    dispatch_async(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString * key, HLSDownloadItem *obj, BOOL *stop) {
            if (obj.status == HLSDownloadItemStatusDownloading || obj.status == HLSDownloadItemStatusWaiting) {
                [obj pause];
            }
        }];
    });
}

- (void)stopAllDownload;
{
    dispatch_async(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HLSDownloadItem *obj, BOOL *stop) {
            if (obj.status != HLSDownloadItemStatusFinished) {
                [obj stop];
            }
        }];
        
        [self.itemDic removeAllObjects];
    });
}

- (void)removeAllCache;
{
    dispatch_sync(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *  key, HLSDownloadItem *  obj, BOOL *  stop) {
            [obj clearCache];
        }];
    });
    
    [self reset];
}

- (long long)videoCacheSize;
{
    __block int64_t size = 0;
    dispatch_sync(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HLSDownloadItem *obj, BOOL *  stop) {
            size = size + obj.size;
        }];
    });
    return size;
}

- (NSArray<HLSDownloadItem *> *)AllItems;
{
    __block NSMutableArray *allItems = [[NSMutableArray alloc] init];
    dispatch_sync(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *  key, HLSDownloadItem *  obj, BOOL *  stop) {
             [allItems addObject:obj];
        }];
    });
    return allItems;
}

- (NSArray<HLSDownloadItem *> *)downloadedItems;
{
    __block NSMutableArray *downloaded = [[NSMutableArray alloc] init];
    dispatch_sync(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *  key, HLSDownloadItem *  obj, BOOL *  stop) {
            if (obj.status == HLSDownloadItemStatusFinished) {
                [downloaded addObject:obj];
            }
        }];
    });
    return downloaded;
}

- (NSArray<HLSDownloadItem *> *)downloadingItems;
{
    __block NSMutableArray *downloading = [[NSMutableArray alloc] init];
    dispatch_sync(hls_downloader_queue(), ^{
        [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *  key, HLSDownloadItem *  obj, BOOL *  stop) {
            if (obj.status != HLSDownloadItemStatusFinished) {
                [downloading addObject:obj];
            }
        }];
    });
    return downloading;
}

#pragma mark - private
- (instancetype)init
{
    if (self = [super init]) {
        _allowCellular = NO;
        _maxTaskCount = 1;
        _enableSpeed = NO;
        
        _operationQueue = [[NSOperationQueue alloc] init];
        NSString *queueName = @"HLSDOWNLOADER_QUEUE_NAME";
        _operationQueue.name = queueName;
        _operationQueue.maxConcurrentOperationCount = _maxTaskCount;
        
        _fileContainer = [[HLSFileContainer alloc] initWithHLSContainerName:nil];
        
        [self addAppObserver];
        [self unarchiveDowbloaderItem];
        [self controlNetWorkSwitch];
    }
    return self;
}

- (void)reset
{
    [self.itemDic removeAllObjects];
}

- (void)controlNetWorkSwitch
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self startAllDownload];
        }
        else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            if (self.allowCellular) {
                [self startAllDownload];
            }else{
                [self pauseAllDownload];
            }
        }
        else{
            [self pauseAllDownload];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark - archive
- (void)addAppObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterBg:) name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminal:) name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)applicationWillEnterBg:(NSNotification *)noti
{
    [self archiveDownloaderItems];
}

- (void)applicationWillTerminal:(NSNotification *)noti
{
    [self pauseAllDownload];
    [self archiveDownloaderItems];
}

- (void)archiveDownloaderItems;
{
    dispatch_sync(hls_downloader_queue(), ^{
        [self _archiveDownloaderItems];
    });
}

- (void)unarchiveDowbloaderItem;
{
    dispatch_sync(hls_downloader_queue(), ^{
        [self _unarchiveDowbloaderItem];
    });
}

- (void)_archiveDownloaderItems
{
    NSData *data = [self.itemDic yy_modelToJSONData];
    [self.fileContainer archiveData:data];
}

- (void)_unarchiveDowbloaderItem
{
    id obj = [self.fileContainer unarchiveObject];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.itemDic = [[NSMutableDictionary alloc] initWithDictionary:obj];
    }
    else if(!self.itemDic){
        self.itemDic = [[NSMutableDictionary alloc] init];
    }
}

#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
