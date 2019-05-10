//
//  HLSDownloadItem.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HLSDownloadItemDelegate;

typedef NS_ENUM(NSUInteger, HLSDownloadItemStatus){
    HLSDownloadItemStatusWaiting,
    HLSDownloadItemStatusDownloading,
    HLSDownloadItemStatusPaused,
    HLSDownloadItemStatusFinished,
    HLSDownloadItemStatusFailed,
    HLSDownloadItemStatusLostServer,
};

NS_ASSUME_NONNULL_BEGIN

@interface HLSDownloadItem : NSObject
@property (nonatomic, assign, readonly) float priority;
@property (nonatomic, copy, readonly) NSString *uniqueId;
@property (nonatomic, copy, readonly) NSString *downloadUrl;
@property (nonatomic, assign, readonly) HLSDownloadItemStatus status;
@property (nonatomic, weak) id <HLSDownloadItemDelegate> delegate;

/**
 创建下载对象

 @param url 下载的URL
 @param unique 唯一标识符, 为空则会根据URL生成md5
 @param priority 下载的优先级
 @param opQueue 下载队列,为空则会为mainQueue
 @return 下载对象
 */
- (instancetype)initWithUrl:(NSString *)url uniqueId:(nullable NSString *)unique priority:(float)priority queue:(nullable NSOperationQueue *)opQueue;
@end

@protocol HLSDownloadItemDelegate <NSObject>
- (void)downloadItem:(HLSDownloadItem *)item statusChanged:(HLSDownloadItemStatus)status;
- (void)downloadItem:(HLSDownloadItem *)item size:(int64_t)downloadedSize total:(int64_t)totalSize;
- (void)downloadItem:(HLSDownloadItem *)item speed:(NSString *)speed;
@end
NS_ASSUME_NONNULL_END
