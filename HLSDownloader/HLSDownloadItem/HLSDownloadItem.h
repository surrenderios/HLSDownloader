//
//  HLSDownloadItem.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HLSDownloadItem;

typedef NS_ENUM(NSUInteger, HLSDownloadItemStatus){
    HLSDownloadItemStatusWaiting,
    HLSDownloadItemStatusDownloading,
    HLSDownloadItemStatusPaused,
    HLSDownloadItemStatusFinished,
    HLSDownloadItemStatusFailed,
    HLSDownloadItemStatusLostServer,
};

@protocol HLSDownloadItemDelegate <NSObject>
- (void)downloadItem:(HLSDownloadItem *)item statusChanged:(HLSDownloadItemStatus)status;
- (void)downloadItem:(HLSDownloadItem *)item size:(int64_t)downloadedSize total:(int64_t)totalSize;
- (void)downloadItem:(HLSDownloadItem *)item speed:(NSUInteger)speed;
@end


NS_ASSUME_NONNULL_BEGIN

@interface HLSDownloadItem : NSObject
@property (nonatomic, copy, readonly) NSString *downloadUrl;
@property (nonatomic, copy, readonly) NSString *uniqueId;
@property (nonatomic, assign, readonly) float priority;
@property (nonatomic, assign, readonly) HLSDownloadItemStatus status;
@property (nonatomic, weak) id <HLSDownloadItemDelegate> delegate;
- (instancetype)initWithUrl:(NSString *)url uniqueId:(NSString *)unique priority:(float)priority;
@end

NS_ASSUME_NONNULL_END
