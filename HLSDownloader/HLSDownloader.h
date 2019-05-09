//
//  HLSDownloader.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLSDownloadItem.h"

/*
 1. 提供 HLS 下载的控制, 是否允许4G, 最大同时下载数量, 显示网络速度, 允许下载完成本地通知
 2. 提供对外增删查改数据的接口
 */

@interface HLSDownloader : NSObject
+ (HLSDownloader *)shareDownloader;

@property (nonatomic, assign) BOOL allowCellular;
@property (nonatomic, assign) NSUInteger maxTaskCount;
@property (nonatomic, assign) BOOL allowLocalPush;
@property (nonatomic, assign) BOOL enableSpeed;

- (void)startDownload:(HLSDownloadItem *)item;
- (void)startDownloadWith:(NSString *)url uniqueId:(NSString *)unique priority:(float)priority;
- (void)pauseDownload:(HLSDownloadItem *)item;
- (void)stopDownload:(HLSDownloadItem *)item;

- (void)startAllDownload;
- (void)pauseAllDownload;
- (void)stopAllDownload;

- (void)removeAllCache;
- (long long)videoCacheSize;

- (NSArray<HLSDownloadItem *> *)downloadedItems;
- (NSArray<HLSDownloadItem *> *)downloadingItems;
@end
