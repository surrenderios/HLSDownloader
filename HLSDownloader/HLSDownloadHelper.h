//
//  HLSDownloadHelper.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/13/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLSDownloadHelper : NSObject
+ (NSString *)uniqueIdWithString:(NSString *)playUrl;
@end

NS_ASSUME_NONNULL_END
