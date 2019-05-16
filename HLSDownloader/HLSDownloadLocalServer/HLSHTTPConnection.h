//
//  HLSHTTPConnection.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/16/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HTTPConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSHTTPConnection : HTTPConnection
@property (nonatomic, assign) BOOL isHalf;
@property (nonatomic, strong) NSFileManager *fm;
@property (nonatomic, strong) NSMutableDictionary *indexMapToTsUrl;
@end

NS_ASSUME_NONNULL_END
