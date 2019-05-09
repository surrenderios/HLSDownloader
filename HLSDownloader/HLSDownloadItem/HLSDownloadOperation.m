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

typedef NS_ENUM(NSUInteger, HLSOperationState){
    HLSOperationStateReady,
    HLSOperationStateExcuting,
    HLSOperationStateFinished,
};

NSString *const HLSDownloadErrorDomain = @"HLSDownloadErrorDomain";

NSError *HLSErrorWithType(NSUInteger type){
    return [NSError errorWithDomain:HLSDownloadErrorDomain
                               code:0
                           userInfo:nil];
}

@interface HLSDownloadOperation ()<NSURLSessionDownloadDelegate>
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) NSUInteger tsStartIndex;

@property (nonatomic, strong) M3U8PlaylistModel *m3u8Model;
// 由第一个分片的大小*分片的数量来预估,
@property (nonatomic, assign) long long fileSize;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *curTask;

@property (nonatomic, assign) NSTimeInterval lastWriteTime;
@property (nonatomic, assign) long long byteWriten;

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
        _tsStartIndex =  startIndex;
        _opState = HLSOperationStateReady;
    }
    return self;
}

#pragma mark - operation super
- (void)start
{
    @synchronized (self) {
        if (self.isCancelled) {
            self.opState = HLSOperationStateFinished;
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
    
}

- (void)cancelOperation
{
    if (self.opState == HLSOperationStateFinished) {
        return;
    }else{
        [super cancel];
        
        if (self.curTask) {
            [self.curTask cancel];
        }
        
        self.opState = HLSOperationStateFinished;
        
        [self resetOperation];
    }
}

- (void)setOpState:(HLSOperationState)opState
{
    NSString *oldKeyPath = [self keyPathFromOpState:self.opState];
    NSString *newKeyPath = [self keyPathFromOpState:opState];
    
    [self willChangeValueForKey:oldKeyPath];
    [self willChangeValueForKey:newKeyPath];
    _opState = opState;
    [self didChangeValueForKey:oldKeyPath];
    [self didChangeValueForKey:newKeyPath];
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
        if (self.m3u8Block) {
            self.m3u8Block(self.urlString, nil, HLSErrorWithType(0));
        }
    }else{
        NSURL *url = [NSURL URLWithString:self.urlString];
        [url loadM3U8AsynchronouslyCompletion:^(M3U8PlaylistModel *model, NSError *error) {
            if (!error) {
                self.m3u8Model = model;
                [self startDownloadTs];
            }
            if (self.m3u8Block) {
                self.m3u8Block(self.urlString, model, error);
            }
        }];
    }
}

#pragma mark - download ts
- (void)startDownloadTs
{
    M3U8SegmentInfoList *tsList = self.m3u8Model.mainMediaPl.segmentList;
    if (self.tsStartIndex < tsList.count) {
        M3U8SegmentInfo *segInfo = [tsList segmentInfoAtIndex:self.tsStartIndex];
        if (segInfo.mediaURL) {
            [self startDownloadTsWithUrl:segInfo.mediaURL];
        }
    }else{
        self.opState = HLSOperationStateFinished;
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
    if (self.failedBlock) {
        self.failedBlock(self.urlString, self.tsStartIndex, error);
    }
}

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session API_AVAILABLE(ios(7.0), watchos(2.0), tvos(9.0)) API_UNAVAILABLE(macos);
{
    
}
#pragma mark - NSURLSessionTaskDelegate
/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error;
{
    if (error) {
        if (self.failedBlock) {
            self.failedBlock(self.urlString, self.tsStartIndex, error);
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
{
    
}

#pragma mark - NSURLSessionDownloadDelegate

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;
{
    if (self.tsBlock) {
        self.tsBlock(self.urlString, downloadTask.originalRequest.URL, location.absoluteString, self.tsStartIndex, YES);
    }
    
    [self startDownloadTs];
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
{
    if (self.progressBlock) {
        [self calculateProgress:totalBytesWritten all:totalBytesExpectedToWrite];
    }
    
    if (self.speedBlock) {
        [self calculateSpeed:totalBytesWritten];
    }
}

#pragma mark - helper
- (void)calculateProgress:(int64_t)totalBytesWritten all:(int64_t)totalBytesExpectedToWrite
{
    if (self.fileSize == 0) {
        self.fileSize = self.m3u8Model.mainMediaPl.segmentList.count * totalBytesExpectedToWrite;
    }
    
    NSProgress *progress = [[NSProgress alloc] init];
    progress.totalUnitCount = self.fileSize;
    progress.completedUnitCount = totalBytesWritten;
    
    self.progressBlock(self.urlString, progress);
}

- (void)calculateSpeed:(int64_t)totalBytesWritten
{
    if (!self.lastWriteTime) {
        self.lastWriteTime = CFAbsoluteTimeGetCurrent();
    }else{
        NSTimeInterval time = CFAbsoluteTimeGetCurrent() - self.lastWriteTime;
        int64_t deltaSize = totalBytesWritten - self.byteWriten;
        if (deltaSize > 0) {
            int64_t kbSize = deltaSize / 1024;
            NSString *speedDes;
            if(kbSize < 1024){
                float speed = kbSize/time;
                speedDes = [NSString stringWithFormat:@"%.2f KB/S",speed];
            }else{
                float speed = kbSize / 1024 / time;
                speedDes = [NSString stringWithFormat:@"%.2f M/S",speed];
            }
            self.lastWriteTime = CFAbsoluteTimeGetCurrent();
            
            self.speedBlock(self.urlString, speedDes);
        }
    }
    
    self.byteWriten = totalBytesWritten;
}
@end
