//
//  HLSDownloadItem+private.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/7/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloadItem.h"
#import <AFNetworking.h>
#import "HLSDownloadOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSDownloadItem ()
@property (nonatomic, assign) BOOL enableSpeed;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) HLSDownloadOperation *operation;
@end

@interface HLSDownloadItem (private)
- (void)startDownload;
- (void)waitingDownload;
- (void)pauseDownload;
- (void)stopDownload;
@end

NS_ASSUME_NONNULL_END
