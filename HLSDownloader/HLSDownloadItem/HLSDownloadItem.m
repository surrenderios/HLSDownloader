//
//  HLSDownloadItem.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloadItem.h"
#import "HLSDownloadItem+Private.h"

@implementation HLSDownloadItem

- (instancetype)initWithUrl:(NSString *)url uniqueId:(nullable NSString *)unique priority:(NSOperationQueuePriority)priority;
{
    if (self = [super init]) {
        _downloadUrl = url;
        _uniqueId = (unique.length != 0) ? unique : [self uniqueIdWithUrlString:url];
        _priority = priority;
        
    }
    return self;
}

- (void)start;
{
    [self startAtIndex:0];
}

- (void)startAtIndex:(NSUInteger)tsIndex;
{
    if (self.operation.isExecuting) {
        return;
    }
    
    // recreate operation
    NSUInteger inIndex = tsIndex;
    if (self.operation) {
        tsIndex = self.operation.tsIndex;
        self.operation = nil;
    }
    self.operation = [[HLSDownloadOperation alloc] initWithUrlStr:self.downloadUrl tsStartIndex:inIndex];
    self.operation.queuePriority = self.priority;
    self.operation.delegate = self;

    [self.opQueue addOperation:self.operation];
    
    [self setStatus:HLSDownloadItemStatusWaiting];
}

- (void)pause;
{
    if (self.operation.isExecuting) {
        [self.operation cancel];
    }
}

- (void)resume;
{
    if (self.operation && !self.operation.isExecuting) {
        [self.opQueue addOperation:self.operation];
    }
}

- (void)stop;
{
    if (self.operation) {
        [self.operation cancel];
        self.operation = nil;
    }
}

- (int64_t)size;
{
    return self.operation.totalTsByteDownload;
}

- (void)clearCache
{
    
}

#pragma mark private
- (instancetype)init
{
    if (self = [super init]) {
        _status = HLSDownloadItemStatusWaiting;
    }
    return self;
}

- (NSOperationQueue *)opQueue
{
    if (!_opQueue) {
        _opQueue = [NSOperationQueue mainQueue];
    }
    return _opQueue;
}

- (NSString *)uniqueIdWithUrlString:(NSString *)urlString
{
    return [HLSDownloadOperation md5NameForUrlString:urlString];
}

- (void)setStatus:(HLSDownloadItemStatus)status
{
    _status = status;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(downloadItem:statusChanged:)]) {
            [self.delegate downloadItem:self statusChanged:status];
        }
    });
}


#pragma mark - delegate
- (void)hlsDownloadOperation:(HLSDownloadOperation *)op downloadStatusChanged:(HLSOperationState)status;
{
    if (status == HLSOperationStateFinished) {
        [self setStatus:HLSDownloadItemStatusFinished];
    }
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op m3u8:(nullable NSString *)m3u8Str error:(nullable NSError *)error;
{
    if (!error) {
        [self setStatus:HLSDownloadItemStatusDownloading];
    }else{
        if (error.code == -999) {
            [self setStatus:HLSDownloadItemStatusPaused];
        }else if(error.code == -1001){
            [self setStatus:HLSDownloadItemStatusLostServer];
        }else{
            [self setStatus:HLSDownloadItemStatusFailed];
        }
    }
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op downloadedSize:(int64_t)downloaded totalSize:(int64_t)total;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(downloadItem:size:total:)]) {
            [self.delegate downloadItem:self size:downloaded total:total];
        }
    });
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op estimateSpeed:(NSString *)speed;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(downloadItem:speed:)]) {
            [self.delegate downloadItem:self speed:speed];
        }
    });
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op tsDownloadedIn:(NSUInteger)tsIndex fromRemoteUrl:(NSURL *)from toLocal:(NSURL *)localUrl;
{
    
}

- (void)hlsDownloadOperation:(HLSDownloadOperation *)op failedAtIndex:(NSUInteger)tsIndex error:(NSError *)error;
{
    if (error.code == -999) {
        [self setStatus:HLSDownloadItemStatusPaused];
    }else if(error.code == -1001){
        [self setStatus:HLSDownloadItemStatusLostServer];
    }else{
        [self setStatus:HLSDownloadItemStatusFailed];
    }
}

#pragma mark -
+ (NSArray *)modelPropertyBlacklist {
    return @[@"delegate",@"fileMgr",@"opQueue",@"operation"];
}

#pragma mark -
- (void)dealloc
{
    NSLog(@">>>%s",__FUNCTION__);
}
@end
