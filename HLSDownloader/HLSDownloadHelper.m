//
//  HLSDownloadHelper.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/13/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloadHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HLSDownloadHelper
+ (NSString *)uniqueIdWithString:(NSString *)playUrl
{
    NSString *md5 = [self md5NameForUrlString:playUrl];
    if ([md5.pathExtension isEqualToString:@"m3u8"]) {
        return [md5 stringByDeletingPathExtension];
    }
    return md5;
}

+ (NSString *)md5NameForUrlString:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    // File system has file name length limit, we need to check if ext is too long, we don't add it to the filename
    if (ext.length > (NAME_MAX - CC_MD5_DIGEST_LENGTH * 2 - 1)) {
        ext = nil;
    }
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], ext.length == 0 ? @"" : [NSString stringWithFormat:@".%@", ext]];
    return filename;
}
@end
