//
//  HLSDownloadItem+Private.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/10/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <HLSDownloader/HLSDownloader.h>
#import "HLSDownloadOperation.h"
#import "HLSDownloadFileManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSDownloadItem ()<HLSDownloadOperationDelegate>
@property (nonatomic, assign) BOOL enableSpeed;
@property (nonatomic, strong) HLSDownloadFileManager *fileMgr;
@property (nonatomic, strong) NSOperationQueue *opQueue;
@property (nonatomic, strong, nullable) HLSDownloadOperation *operation;

- (void)start;
- (void)startAtIndex:(NSUInteger)tsIndex;

- (void)pause;
- (void)resume;

- (void)stop;

- (int64_t)size;
- (void)clearCache;
@end

NS_ASSUME_NONNULL_END
