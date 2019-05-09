//
//  HLSDownloadOperation.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/8/19.
//  Copyright © 2019 Alex. All rights reserved.
//

/*
 1. 外部传入URL, 当前 Operation 根据 URL 进行 M3U8 文件的下载和解析
 2. 提供 M3U8 解析的结果, 下载的进度, 下载的速度
 3. 提供每一个分片文件下载完成回调, 用于外部保存下载的数据到指定位置
 4. 提供断点下载开始的位置, 以分片数的 startIndex 开始
 */

#import <Foundation/Foundation.h>
@class HLSDownloadOperation;

extern NSString *const HLSDownloadErrorDomain;

typedef void (^HLSM3u8ParseHanlder)(NSString *urlString, id m3u8Info, NSError *error);
typedef void (^HLSProgressHandler)(NSString *urlString, NSProgress *downloadProgress);
typedef void (^HLSSpeedHandler)(NSString *urlString, NSString *speedDes);
typedef void (^HLSTSCompleteHandler)(NSString *urlString, NSURL *tsUrl, NSString *targetPath,NSUInteger tsIndex, BOOL finished);
typedef void (^HLSTSFailedHandler)(NSString *urlString, NSUInteger tsIndex, NSError *error);

NS_ASSUME_NONNULL_BEGIN
@interface HLSDownloadOperation : NSOperation
@property (nonatomic, copy) HLSM3u8ParseHanlder m3u8Block;
@property (nonatomic, copy) HLSProgressHandler progressBlock;
@property (nonatomic, copy) HLSSpeedHandler speedBlock;
@property (nonatomic, copy) HLSTSCompleteHandler tsBlock;
@property (nonatomic, copy) HLSTSFailedHandler failedBlock;

- (instancetype)initWithUrlStr:(NSString *)urlString;
- (instancetype)initWithUrlStr:(NSString *)urlString tsStartIndex:(NSUInteger)startIndex;
@end
NS_ASSUME_NONNULL_END
