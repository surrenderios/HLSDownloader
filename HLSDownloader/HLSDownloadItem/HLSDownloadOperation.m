//
//  HLSDownloadOperation.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/8/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloadOperation.h"

#import <M3U8Kit/M3U8Kit.h>
#import <NSURL+m3u8.h>

NSString *const HLSDownloadErrorDomain = @"HLSDownloadErrorDomain";

NSError *HLSErrorWithType(NSUInteger type){
    return [NSError errorWithDomain:HLSDownloadErrorDomain
                               code:0
                           userInfo:nil];
}

@interface HLSDownloadOperation ()<NSURLSessionDownloadDelegate>

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign, readwrite) NSUInteger tsIndex;

@property (nonatomic, strong) M3U8PlaylistModel *m3u8Model;
// 由第一个分片的大小*分片的数量来预估,
@property (nonatomic, assign) int64_t fileSize;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *curTask;

@property (nonatomic, assign) NSTimeInterval lastWriteTime;
@property (nonatomic, assign, readwrite) int64_t totalTsByteDownload;

@property (nonatomic, assign) HLSOperationState opState;
@end

@implementation HLSDownloadOperation

- (instancetype)initWithUrlStr:(NSString *)urlString;
{
    return [self initWithUrlStr:urlString tsStartIndex:0];
}

- (instancetype)initWithUrlStr:(NSString *)urlString tsStartIndex:(NSUInteger)startIndex;
{
    if (self = [super init]) {
        _urlString = urlString;
        _tsIndex =  startIndex;
        _opState = HLSOperationStateReady;
        _opUniqueId = [HLSDownloadHelper uniqueIdWithString:urlString];
    }
    return self;
}

#pragma mark - operation super
- (void)start
{
    @synchronized (self) {
        if (self.isCancelled) {
            [self resetOperation];
        }else{
            self.opState = HLSOperationStateExcuting;
            [self startDOwnload];
        }
    }
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isReady
{
    return (self.opState == HLSOperationStateReady) && [super isReady];
}

- (BOOL)isExecuting
{
    return (self.opState == HLSOperationStateExcuting);
}

- (BOOL)isFinished
{
    return (self.opState == HLSOperationStateFinished);
}

- (void)cancel
{
    @synchronized (self) {
        [self cancelOperation];
    }
}

- (void)resetOperation
{
    [self.curTask cancel];
    self.curTask = nil;
    [self.session invalidateAndCancel];
    self.session = nil;
    
    self.opState = HLSOperationStateFinished;
}

- (void)cancelOperation
{
    if (self.opState == HLSOperationStateFinished) {
        return;
    }else{
        [super cancel];
        [self resetOperation];
    }
}

- (void)setOpState:(HLSOperationState)opState
{
    if (self.opState == opState) {
        return;
    }
    
    NSString *oldKeyPath = [self keyPathFromOpState:self.opState];
    NSString *newKeyPath = [self keyPathFromOpState:opState];
    
    [self willChangeValueForKey:oldKeyPath];
    [self willChangeValueForKey:newKeyPath];
    _opState = opState;
    [self didChangeValueForKey:oldKeyPath];
    [self didChangeValueForKey:newKeyPath];
    
    if([self.delegate respondsToSelector:@selector(hlsDownloadOperation:downloadStatusChanged:)]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate hlsDownloadOperation:self downloadStatusChanged:self.opState];
        });
    }
}

- (NSString *)keyPathFromOpState:(HLSOperationState)state
{
    switch (state) {
        case HLSOperationStateReady:
            return @"isReady";
            break;
        case HLSOperationStateExcuting:
            return @"isExcuting";
            break;
        case HLSOperationStateFinished:
            return @"isFinished";
            break;
        default:
            break;
    }
}

#pragma mark - parse m3u8
- (void)startDOwnload
{
    if (!self.session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    
    [self startDownloadM3u8];
}

- (void)startDownloadM3u8
{
    if (self.urlString.length == 0) {
        if ([self.delegate respondsToSelector:@selector(hlsDownloadOperation:m3u8:error:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate hlsDownloadOperation:self m3u8:nil error:HLSErrorWithType(0)];
            });
        }
        
        [self resetOperation];
    }else{
        NSURL *url = [NSURL URLWithString:self.urlString];
        [url loadM3U8AsynchronouslyCompletion:^(M3U8PlaylistModel *model, NSError *error) {
            if (!error) {
                self.m3u8Model = model;
                [self startDownloadTs];
            }else{
                [self resetOperation];
            }
            if ([self.delegate respondsToSelector:@selector(hlsDownloadOperation:m3u8:error:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.delegate hlsDownloadOperation:self m3u8:model.mainMediaPl.originalText error:error];
                });
            }
        }];
    }
}

#pragma mark - download ts
- (void)startDownloadTs
{
    M3U8SegmentInfoList *tsList = self.m3u8Model.mainMediaPl.segmentList;
    if (self.tsIndex < tsList.count) {
        M3U8SegmentInfo *segInfo = [tsList segmentInfoAtIndex:self.tsIndex];
        if (segInfo.mediaURL) {
            [self startDownloadTsWithUrl:segInfo.mediaURL];
        }
    }else{
        [self resetOperation];
    }
}

- (void)startDownloadTsWithUrl:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.curTask = [self.session downloadTaskWithRequest:request];
    [self.curTask resume];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error;
{
    [self callFailedDelegateWithError:error];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session API_AVAILABLE(ios(7.0), watchos(2.0), tvos(9.0)) API_UNAVAILABLE(macos);
{
#warning todo support background download
}
#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error;
{
    [self callFailedDelegateWithError:error];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
{
    
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;
{
    if ([self.delegate respondsToSelector:@selector(hlsDownloadOperation:tsDownloadedIn:fromRemoteUrl:toLocal:)]) {
        [self.delegate hlsDownloadOperation:self tsDownloadedIn:self.tsIndex fromRemoteUrl:downloadTask.originalRequest.URL toLocal:location];
    }
    
    self.tsIndex ++;
    [self startDownloadTs];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
{
    self.totalTsByteDownload = self.totalTsByteDownload + bytesWritten;
    
    if ([self.delegate respondsToSelector:@selector(hlsDownloadOperation:downloadedSize:totalSize:)]) {
        [self calculateProgress:totalBytesWritten all:totalBytesExpectedToWrite];
    }
    
    if (self.enableSpeed) {
        if ([self.delegate respondsToSelector:@selector(hlsDownloadOperation:estimateSpeed:)]) {
            [self calculateSpeed:bytesWritten];
        }
    }
}

#pragma mark - helper
- (void)calculateProgress:(int64_t)totalBytesWritten all:(int64_t)totalBytesExpectedToWrite
{
    if (self.fileSize == 0) {
        self.fileSize = self.m3u8Model.mainMediaPl.segmentList.count * totalBytesExpectedToWrite;
        
        if (self.tsIndex != 0) {
            self.totalTsByteDownload = self.tsIndex * totalBytesExpectedToWrite;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate hlsDownloadOperation:self downloadedSize:self.totalTsByteDownload totalSize:self.fileSize];
    });
}

- (void)calculateSpeed:(int64_t)bytesWritten
{
    if (self.lastWriteTime == 0) {
        self.lastWriteTime = CFAbsoluteTimeGetCurrent();
        return;
    }
    
    NSTimeInterval time = CFAbsoluteTimeGetCurrent() - self.lastWriteTime;
    if (bytesWritten > 0) {
        NSLog(@"%f,%lld",time,bytesWritten);
        NSString *speedDes = nil;
        if (bytesWritten < 1024) {
            float speed = bytesWritten / time;
            speedDes = [NSString stringWithFormat:@"%.2f B/S",speed];
        }
        else if(bytesWritten < 1024  * 1024){
            float speed = bytesWritten / 1024 / time;
            speedDes = [NSString stringWithFormat:@"%.2f KB/S",speed];
        }else{
            float speed = bytesWritten / 1024 / time;
            speedDes = [NSString stringWithFormat:@"%.2f M/S",speed];
        }
        self.lastWriteTime = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate hlsDownloadOperation:self estimateSpeed:speedDes];
        });
    }
}

- (void)callFailedDelegateWithError:(NSError *)error
{
    if (!error) {
        return;
    }

    [self resetOperation];
    
    if ([self.delegate respondsToSelector:@selector(hlsDownloadOperation:failedAtIndex:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate hlsDownloadOperation:self failedAtIndex:self.tsIndex error:error];
        });
    }
}

#pragma mark -
- (void)dealloc
{
    NSLog(@">>>%s",__FUNCTION__);
}
@end
