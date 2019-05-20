//
//  HLSDownloadOperation.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/8/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLSDownloadHelper.h"

@protocol HLSDownloadOperationDelegate;

extern NSString *const HLSDownloadErrorDomain;

typedef NS_ENUM(NSUInteger, HLSOperationState){
    HLSOperationStateReady,
    HLSOperationStateExcuting,
    HLSOperationStateFinished,
};

NS_ASSUME_NONNULL_BEGIN
@interface HLSDownloadOperation : NSOperation
@property (nonatomic, assign) BOOL enableSpeed;
@property (nonatomic, assign, readonly) NSUInteger tsIndex;
@property (nonatomic, assign, readonly) int64_t totalTsByteDownload;

/**
 根据 URL 生成的 MD5
 */
@property (nonatomic, copy, readonly) NSString *opUniqueId;

/**
 下载回调
 */
@property (nonatomic, weak) id<HLSDownloadOperationDelegate> delegate;


/**
 根据传入的URL创建下载对象

 @param urlString 下载的URL
 @return 下载对象
 */
- (instancetype)initWithUrlStr:(NSString *)urlString;


/**
 根据传入的URL创建下载对象

 @param urlString 下载的URL
 @param startIndex ts分片开始位置
 @return 下载对象
 */
- (instancetype)initWithUrlStr:(NSString *)urlString tsStartIndex:(NSUInteger)startIndex;

@end

@protocol HLSDownloadOperationDelegate <NSObject>
- (void)hlsDownloadOperation:(HLSDownloadOperation *)op downloadStatusChanged:(HLSOperationState)status;
- (void)hlsDownloadOperation:(HLSDownloadOperation *)op m3u8:(nullable NSString *)m3u8Str error:(nullable NSError *)error;
- (void)hlsDownloadOperation:(HLSDownloadOperation *)op downloadedSize:(int64_t)downloaded totalSize:(int64_t)total;
- (void)hlsDownloadOperation:(HLSDownloadOperation *)op estimateSpeed:(NSString *)speed;
- (void)hlsDownloadOperation:(HLSDownloadOperation *)op tsDownloadedIn:(NSUInteger)tsIndex fromRemoteUrl:(NSURL *)from toLocal:(NSURL *)localUrl;
- (void)hlsDownloadOperation:(HLSDownloadOperation *)op failedAtIndex:(NSUInteger)tsIndex error:(NSError *)error;
@end
NS_ASSUME_NONNULL_END
