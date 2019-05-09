//
//  HLSDownloader.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloader.h"
#import "HLSDownloadItem+private.h"

@interface HLSDownloader ()
@property (nonatomic, assign) long long cacheSize;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
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
    
    [self.items enumerateObjectsUsingBlock:^(HLSDownloadItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.enableSpeed = enableSpeed;
    }];
}

- (void)startDownload:(HLSDownloadItem *)item;
{
    item.enableSpeed = self.enableSpeed;
    if (!item.downloadTask) {
        item.sessionManager = self.sessionManager;
    }
    [self.items addObject:item];
    
    [self controlDownload];
}
- (void)startDownloadWith:(NSString *)url uniqueId:(NSString *)unique priority:(float)priority;
{
    HLSDownloadItem *item = [[HLSDownloadItem alloc] initWithUrl:url uniqueId:unique priority:priority];
    [self startDownload:item];
}
- (void)pauseDownload:(HLSDownloadItem *)item;
{
    [item pauseDownload];
    
    [self controlDownload];
}
- (void)stopDownload:(HLSDownloadItem *)item;
{
    [item stopDownload];
    
    [self controlDownload];
}

- (void)startAllDownload;
{
    [self controlDownload];
}
- (void)pauseAllDownload;
{
    [self.items enumerateObjectsUsingBlock:^(HLSDownloadItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.status == HLSDownloadItemStatusDownloading || item.status == HLSDownloadItemStatusWaiting) {
            [item pauseDownload];
        }
    }];
}
- (void)stopAllDownload;
{
    [self.items enumerateObjectsUsingBlock:^(HLSDownloadItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        [item stopDownload];
    }];
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
    __block NSMutableArray *downloaded = [[NSMutableArray alloc] init];
    [self.items enumerateObjectsUsingBlock:^(HLSDownloadItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.status == HLSDownloadItemStatusFinished) {
            [downloaded addObject:item];
        }
    }];
    
    return downloaded;
}
- (NSArray<HLSDownloadItem *> *)downloadingItems;
{
    __block NSMutableArray *downloading = [[NSMutableArray alloc] init];
    [self.items enumerateObjectsUsingBlock:^(HLSDownloadItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.status != HLSDownloadItemStatusFinished) {
            [downloading addObject:item];
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
        _allowLocalPush = NO;
        _enableSpeed = NO;
        
        _cacheSize = 0;
        _items = [[NSMutableArray alloc] init];
        
        _operationQueue = [[NSOperationQueue alloc] init];
        NSString *queueName = @"HLSDOWNLOADER_QUEUE_NAME";
        _operationQueue.name = queueName;
        _operationQueue.maxConcurrentOperationCount = _maxTaskCount;
    }
    return self;
}

- (AFURLSessionManager *)sessionManager
{
    if (!_sessionManager) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfig];
    }
    return _sessionManager;
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

- (void)controlMaxDownloadCount
{
#warning todo 控制同时最大的下载数量
}

- (void)controlDownload
{
#warning todo 控制下载的优先级
    NSUInteger downloading = 0;
    for(HLSDownloadItem *item in self.items){
        if (downloading < self.maxTaskCount) {
            [item startDownload];
            downloading ++;
            NSLog(@"startDownload");
        }
    }
}
@end
