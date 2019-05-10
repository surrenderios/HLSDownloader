//
//  HLSDownloader.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloader.h"
#import "HLSDownloader+private.h"
#import "HLSDownloadItem+private.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface HLSDownloader ()
@property (nonatomic, assign) int64_t cacheSize;
@property (nonatomic, strong) NSMutableDictionary<NSString *, HLSDownloadItem *> *itemDic;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSLock *lock;
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
    
    [self.lock lock];
    [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HLSDownloadItem *item, BOOL *stop) {
        item.enableSpeed = enableSpeed;
    }];
    [self.lock unlock];
}

- (void)startDownload:(HLSDownloadItem *)item;
{
    item.enableSpeed = self.enableSpeed;
    [self.operationQueue addOperation:item.operation];
    
    [self.itemDic setObject:item forKey:item.uniqueId];
}

- (void)startDownloadWith:(NSString *)url uniqueId:(NSString *)unique priority:(float)priority;
{
    HLSDownloadItem *item = [[HLSDownloadItem alloc] initWithUrl:url uniqueId:unique priority:0 queue:self.operationQueue];
    [self startDownload:item];
}

- (void)pauseDownload:(HLSDownloadItem *)item;
{
    [item pause];
}

- (void)stopDownload:(HLSDownloadItem *)item;
{
    [item stop];
}

- (void)startAllDownload;
{
    [self.lock lock];
    [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HLSDownloadItem *obj, BOOL *stop) {
        if (obj.status != HLSDownloadItemStatusDownloading) {
            [obj start];
        }
    }];
    [self.lock unlock];
}

- (void)pauseAllDownload;
{
    [self.lock lock];
    [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString * key, HLSDownloadItem *obj, BOOL *stop) {
        if (obj.status == HLSDownloadItemStatusDownloading || obj.status == HLSDownloadItemStatusWaiting) {
            [obj pause];
        }
    }];
    [self.lock unlock];
}

- (void)stopAllDownload;
{
    [self.lock lock];
    [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, HLSDownloadItem *obj, BOOL *stop) {
        if (obj.status != HLSDownloadItemStatusFinished) {
            [obj stop];
        }
    }];
    [self.lock unlock];
}

- (void)removeAllCache;
{
    [self clear];
}

- (long long)videoCacheSize;
{
    return self.cacheSize;
}

- (NSArray<HLSDownloadItem *> *)downloadedItems;
{
    [self.lock lock];
    
    __block NSMutableArray *downloaded = [[NSMutableArray alloc] init];
    [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, HLSDownloadItem * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.status == HLSDownloadItemStatusFinished) {
            [downloaded addObject:obj];
        }
    }];
    [self.lock unlock];
    
    return downloaded;
}

- (NSArray<HLSDownloadItem *> *)downloadingItems;
{
    __block NSMutableArray *downloading = [[NSMutableArray alloc] init];
    [self.itemDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, HLSDownloadItem * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.status != HLSDownloadItemStatusFinished) {
            [downloading addObject:obj];
        }
    }];
    return downloading;
}

#pragma mark - private
- (instancetype)init
{
    if (self = [super init]) {
        _allowCellular = NO;
        _maxTaskCount = 1;
        _enableSpeed = NO;
        
        _cacheSize = 0;
        _itemDic = [[NSMutableDictionary alloc] init];
        
        _operationQueue = [[NSOperationQueue alloc] init];
        NSString *queueName = @"HLSDOWNLOADER_QUEUE_NAME";
        _operationQueue.name = queueName;
        _operationQueue.maxConcurrentOperationCount = _maxTaskCount;
        
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)clear
{
    [self stopAllDownload];
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
@end
