//
//  HLSDownloader+LocalServer.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/16/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSDownloader+LocalServer.h"
#import "HLSDownloader+Private.h"

static NSString *const LocalAddress = @"http://127.0.0.1";

@implementation HLSDownloader (LocalServer)

- (NSString *)localCachedUrlForUrlStr:(NSString *)urlStr uniqueId:(nullable NSString *)uniqueId;
{
    return [self localUrlForUrlStr:urlStr uniqueId:uniqueId];
}

- (NSString *)localPlayingAlongCachingUrlForUrlStr:(NSString *)urlStr uniqueId:(nullable NSString *)uniqueId;
{
    return [self localUrlForUrlStr:urlStr uniqueId:uniqueId];
}

#pragma mark -
- (NSString *)localUrlForUrlStr:(NSString *)urlStr uniqueId:(nullable NSString *)uniqueId;
{
    if (uniqueId.length == 0 && urlStr == 0) {
        return nil;
    }
    
    if(uniqueId.length == 0){
        uniqueId = [HLSDownloadHelper uniqueIdWithString:urlStr];
    }
    
#warning todo 检查正在下载中的是否包含播放的
    
    NSString *localPort = [self localPort];
    if (localPort.length == 0) {
        return urlStr;
    }else{
        NSString *localHost = [NSString stringWithFormat:@"%@:%@/%@/%@.m3u8",LocalAddress,[self localPort],uniqueId,uniqueId];
        return localHost;
    }
}

- (BOOL)startLocalServer
{
    if (!self.localServer) {
        self.localServer = [[HTTPServer alloc] init];
        [self.localServer setPort:8080];
        [self.localServer setType:@"_http._tcp."];
        [self.localServer setName:@"HLSDownloader_Local_Server"];
        [self.localServer setDocumentRoot:self.fileContainer.localServerDocu];
        [self.localServer setConnectionClass:[HLSHTTPConnection class]];
    }
    
    if (self.localServer.isRunning) {
        return YES;
    }
    
    return [self.localServer start:nil];
}

- (void)stopLocalServer
{
    [self.localServer stop:YES];
}

- (NSString *)localPort
{
    BOOL host = [self startLocalServer];
    if (host) {
        return [NSString stringWithFormat:@"%hu",self.localServer.listeningPort];
    }else{
        return nil;
    }
}
@end
