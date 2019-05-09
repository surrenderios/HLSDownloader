//
//  HLSM3U8Parser.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/7/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSM3U8Parser.h"
#import <NSURL+m3u8.h>

NSError *errorWithType(NSUInteger type){
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:100
                           userInfo:nil];
}

@implementation HLSM3U8Parser
- (void)loadM3U8AsynchronouslyWithString:(NSString *)urlString completion:(void (^)(M3U8PlaylistModel *model, NSError *error))completion;
{
    if (urlString.length == 0) {
        completion(nil, errorWithType(0));
    }else{
        NSURL *url = [NSURL URLWithString:urlString];
        [url loadM3U8AsynchronouslyCompletion:completion];
    }
}
@end
