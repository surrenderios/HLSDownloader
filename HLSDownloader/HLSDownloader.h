//
//  HLSDownloader.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLSDownloadItem.h"

@interface HLSDownloader : NSObject

/**
 创建下载单例

 @return 下载管理对象
 */
+ (HLSDownloader *)shareDownloader;

/**
 是否运行流量下载, 切换到流量时会自动暂停所有任务
 */
@property (nonatomic, assign) BOOL allowCellular;

/**
 允许同时下载的最大任务量
 */
@property (nonatomic, assign) NSUInteger maxTaskCount;

/**
 是否允许下载速度
 */
@property (nonatomic, assign) BOOL enableSpeed;

/**
 开始下载任务

 @param item 需要下载的任务
 */
- (void)startDownload:(HLSDownloadItem *)item;

/**
 开始下载任务

 @param url 需要下载的URL
 @param unique 标记下载URL的唯一ID, 为空则为URL进行MD5计算后的字符串
 @param priority 下载的优先级
 */
- (void)startDownloadWith:(NSString *)url
                 uniqueId:(nullable NSString *)unique
                 priority:(float)priority;

/**
 暂停下载任务

 @param item 需要暂停的任务
 */
- (void)pauseDownload:(HLSDownloadItem *)item;

/**
 停止下载任务,并删除该任务

 @param item 需要停止的任务
 */
- (void)stopDownload:(HLSDownloadItem *)item;

/**
 开始下载所有添加的任务, 受最大下载任务量约束
 */
- (void)startAllDownload;

/**
 暂停所有下载的任务
 */
- (void)pauseAllDownload;

/**
 停止下载所有的任务, 并删除
 */
- (void)stopAllDownload;

/**
 移除所有的缓存
 */
- (void)removeAllCache;

/**
 获取所有缓存文件的大小

 @return 缓存文件大小
 */
- (long long)videoCacheSize;


/**
 获取下载完成的任务

 @return 下载完成的任务
 */
- (NSArray<HLSDownloadItem *> *)downloadedItems;


/**
 获取等待中,下载中,下载失败的任务

 @return 等待中,下载中,下载失败的任务
 */
- (NSArray<HLSDownloadItem *> *)downloadingItems;
@end
