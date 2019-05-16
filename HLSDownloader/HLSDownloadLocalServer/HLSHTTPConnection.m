//
//  HLSHTTPConnection.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/16/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSHTTPConnection.h"
#import "HTTPDataResponse.h"
#import "HTTPRedirectResponse.h"

#import "HTTPAsyncFileResponse.h"

#import <M3U8Kit/M3U8LineReader.h>

static NSString *const RemoteTestUrl = @"http://61.138.254.167:5000/nn_vod/nn_x64/aWQ9NWJiZWM1OWExODM2OTg1NWJjOWQ0NWFmMDMxYjM2ZDUmdXJsX2MxPTdhNjg2ZjZlNjc2Nzc1NjE2ZTY3NjM2ODc1NjE2ZTYyNmYyZjMyMzAzMTM4MzEzMDMxMzEyZjM1NjI2MjY1NjMzNTY0MzUzMzYxMzAzMTY0MzgzMTYxNjUzOTYzMzE2MjM0MzA2NDYzMzAzNjY1MzAzMDMxMzUyZjM1NjI2MjY1NjMzNTM5NjEzMTM4MzMzNjM5MzgzNTM1NjI2MzM5NjQzNDM1NjE2NjMwMzMzMTYyMzMzNjY0MzUyZTc0NzMwMCZubl9haz0wMTljNjFlZjk5MDFmNjUyNjkyODA2NjYyNGQwMzlhZjBiJm50dGw9MyZucGlwcz0xOTIuMTY4LjIwNC4xMTI6NTEwMCZuY21zaWQ9MTYwMTAxJm5ncz01Y2MyNzUzNDIzNDY0MThhYTY2YjE0ZjRkMWY0NDY1NyZubmQ9dGVzdC50cy5zdGFyY29yJm5zZD1jbi56Z2R4LmFsbCZuZnQ9dHMmbm5fdXNlcl9pZD13dXl1amluZyZuZHQ9cGhvbmUmbmRpPTBjYjMyZjNlNmJlZWRkMWU5ODhlNTE2NTMxY2IxMTc3Jm5kdj0xLjUuMC4wLjIuU0MtSHVhQ2FpVFYtSVBIT05FLjAuMF9SZWxlYXNlJm5zdD1pcHR2Jm5jYT0lMjZuYWklM2Q1NDc5NjElMjZubl9jcCUzZHpob25nZ3VhbmdjaHVhbmJvJm5hbD0wMTM0NzVjMjVjMDYwN2UwMzU5OTkzOGJmYTNiODExNzg0MTdlNWEzZGM1ZDQy/5bbec59a18369855bc9d45af031b36d5.m3u8";

@implementation HLSHTTPConnection
- (NSString *)filePathForURI:(NSString *)path allowDirectory:(BOOL)allowDirectory
{
    return [super filePathForURI:path allowDirectory:allowDirectory];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    if (!self.fm) {
        self.fm = [NSFileManager defaultManager];
    }
    
    NSString *filePath = [self filePathForURI:path allowDirectory:NO];
    
    // 首先检查是否为请求的m3u8文件
    if ([filePath.pathExtension isEqualToString:@"m3u8"]) {
        
        NSString *m3u8Str;
        // 检查请求的文件本地不存在则直接下载以后保存
        if (![self.fm fileExistsAtPath:filePath]) {
            NSURL *testUrl = [NSURL URLWithString:RemoteTestUrl];
            m3u8Str= [[NSString alloc] initWithContentsOfURL:testUrl encoding:NSUTF8StringEncoding error:nil];
        }else{
            m3u8Str = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
        
        // 需要将 m3u8 文件读取, 然后替换所有的分片远程 URL 为本地服务器 URL
        // 让每一个分片的请求被当前方法拦截
        NSData *m3u8Data = [self convertTsHostToLocalHostInM3U8File:m3u8Str];
        return [[HTTPDataResponse alloc] initWithData:m3u8Data];
    }else{
        // 检查请求的文件本地不存在则重定向到远程服务器
        if (![self.fm fileExistsAtPath:filePath]) {
            NSString *key = [filePath lastPathComponent];
            NSString *tsUrl = [self.indexMapToTsUrl objectForKey:key];
            
            return [[HTTPRedirectResponse alloc] initWithPath:tsUrl];
        }else{
            NSObject<HTTPResponse> *response = [super httpResponseForMethod:method URI:path];
            return response;
        }
    }
}

- (NSData *)convertTsHostToLocalHostInM3U8File:(NSString *)m3u8String
{
    if (!self.indexMapToTsUrl) {
        self.indexMapToTsUrl = [[NSMutableDictionary alloc] init];
    }
    
    NSUInteger tsLineIndex = 0;
    NSMutableString *m3u8 = [[NSMutableString alloc] init];
    M3U8LineReader *reader = [[M3U8LineReader alloc] initWithText:m3u8String];
    while (true) {
        NSString *line = [reader next];
        if (!line) {
            break;
        }
        
        // TS Key Start With #
        // Change TS Url to index
        if (![line hasPrefix:@"#"] && line.length != 0) {
            
            NSString *key = [NSString stringWithFormat:@"%lu.ts",(unsigned long)tsLineIndex];
            [self.indexMapToTsUrl setObject:line forKey:key];
            
            line = key;
            tsLineIndex ++;
        }
        
        [m3u8 appendString:line];
        [m3u8 appendString:@"\r"];
    }
    
    return [m3u8 dataUsingEncoding:NSUTF8StringEncoding];
}
@end
