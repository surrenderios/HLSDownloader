//
//  HLSDownloadItem.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/6/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloadItem.h"
#import "HLSDownloadItem+private.h"

@implementation HLSDownloadItem
#warning todo 设置delegate给task

- (instancetype)initWithUrl:(NSString *)url uniqueId:(NSString *)unique priority:(float)priority;
{
    if (self = [super init]) {
        _downloadUrl = url;
        _uniqueId = (unique.length != 0) ? unique : [self uniqueIdWithUrlString:url];
        _priority = priority;
    }
    return self;
}

#pragma mark private
- (instancetype)init
{
    if (self = [super init]) {
        _status = HLSDownloadItemStatusWaiting;
    }
    return self;
}

- (NSString *)uniqueIdWithUrlString:(NSString *)urlString
{
    return @"";
}
@end
