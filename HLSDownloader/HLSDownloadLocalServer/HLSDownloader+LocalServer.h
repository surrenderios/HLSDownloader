//
//  HLSDownloader+LocalServer.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/16/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <HLSDownloader/HLSDownloader.h>
#import <HTTPServer.h>
#import "HLSHTTPConnection.h"
#import "HLSDownloadHelper.h"
#import "HLSFileContainer+Private.h"


NS_ASSUME_NONNULL_BEGIN

@interface HLSDownloader ()
@property (nonatomic, strong) HTTPServer *localServer;
@end

@interface HLSDownloader (LocalServer)

@end

NS_ASSUME_NONNULL_END
