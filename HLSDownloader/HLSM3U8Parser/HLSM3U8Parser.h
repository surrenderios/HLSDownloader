//
//  HLSM3U8Parser.h
//  HLSDownloader
//
//  Created by Alex_Wu on 5/7/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <M3U8Kit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLSM3U8Parser : NSObject
- (void)loadM3U8AsynchronouslyWithString:(NSString *)urlString completion:(void (^)(M3U8PlaylistModel *model, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
