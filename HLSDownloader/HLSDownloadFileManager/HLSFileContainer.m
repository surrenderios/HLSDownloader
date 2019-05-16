//
//  HLSFileContainer.m
//  HLSDownloader
//
//  Created by Alex_Wu on 5/8/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "HLSFileContainer.h"

@interface HLSFileContainer ()
@property (nonatomic, copy) NSString *containerName;
@property (nonatomic, copy) NSURL *containerUrl;

@property (nonatomic, strong) NSFileManager *fm;
@property (strong, nonatomic, nullable) dispatch_queue_t ioQueue;
@end

@implementation HLSFileContainer
+ (HLSFileContainer *)shareFileContainer;
{
    static HLSFileContainer *fm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fm = [[HLSFileContainer alloc] init];
    });
    return fm;
}

- (instancetype)init
{
    return [self initWithHLSContainerName:nil];
}

- (instancetype)initWithHLSContainerName:(nullable NSString *)containerName;
{
    if (self = [super init]) {
        _ioQueue = dispatch_queue_create("com.alex.HLSDownloader", DISPATCH_QUEUE_SERIAL);
        dispatch_sync(_ioQueue, ^{
            self.fm = [[NSFileManager alloc] init];
        });
        
        _containerName = containerName.length != 0 ? containerName : @"HLSDownloadContainer";
        [self makeContainerWithName:_containerName];
    }
    return self;
}

- (void)clearContainer;
{
    dispatch_sync(self.ioQueue, ^{
        if (![self.fm fileExistsAtPath:self.containerUrl.path]) {
            return;
        }
        
        BOOL removeRet = [self.fm removeItemAtURL:self.containerUrl error:nil];
        if (removeRet) {
            [self makeContainerWithName:self.containerName];
        }else{
            NSLog(@"remove failed");
        }
    });
}

#pragma mark - childContainer
- (void)clearChildContainerWithUniqueId:(NSString *)uniqueId;
{
    if (uniqueId.length == 0) {
        return;
    }
    
    dispatch_sync(self.ioQueue, ^{
        NSURL *childContainerUrl = [self childContainerWithUniqueId:uniqueId];
        if (![self.fm fileExistsAtPath:childContainerUrl.path]) {
            return;
        }
        
        BOOL removeRet = [self.fm removeItemAtURL:childContainerUrl error:nil];
        if (!removeRet) {
            NSLog(@"remove child container with uniqueId %@ failed",uniqueId);
        }
    });
}

- (id)readM3U8WithUniqueId:(NSString *)uniqueId;
{
    __block NSData *data = nil;
    dispatch_sync(self.ioQueue, ^{
        NSURL *toPath = [self m3u8UrlInChildContainer:uniqueId];
        if ([self.fm fileExistsAtPath:toPath.path]) {
            data = [self.fm contentsAtPath:toPath.path];
        }
    });
    return data;
}

- (void)cacheM3U8:(NSString *)m3u8 withUniqueId:(NSString *)uniqueId;
{
    if (uniqueId.length == 0 || !m3u8) {
        return;
    }
    
    dispatch_sync(self.ioQueue, ^{
        
        [self validateChildContainerWithUniqueId:uniqueId];
        
        NSURL *toPath = [self m3u8UrlInChildContainer:uniqueId];
        
        BOOL removeRet = YES;
        if ([self.fm fileExistsAtPath:toPath.path]) {
            removeRet = [self.fm removeItemAtPath:toPath.path error:nil];
        }
        
        if (removeRet) {
            NSError *error;
            NSData *data = [m3u8 dataUsingEncoding:NSUTF8StringEncoding];
            BOOL  createRet = [data writeToURL:toPath options:NSDataWritingAtomic error:&error];
            if (!createRet) {
                NSLog(@"save m3u8 failed,error:%@",error);
            }
        }
    });
}

- (NSURL *)readTsInContainer:(NSString *)uniqueId url:(NSURL *)tsUrl index:(NSUInteger)tsIndex;
{
    __block NSURL *url = nil;
    dispatch_sync(self.ioQueue, ^{
        url = [self tsPathForUniqueId:uniqueId url:tsUrl index:tsIndex];
        if (![self.fm fileExistsAtPath:url.path]) {
            url = nil;
        }
    });
    return url;
}

- (void)cacheTsInContainer:(NSString *)uniqueId url:(NSURL *)tsUrl index:(NSUInteger)tsIndex content:(id)data;
{
    if (uniqueId.length == 0) {
        return;
    }
    
    dispatch_sync(self.ioQueue, ^{
        [self validateChildContainerWithUniqueId:uniqueId];
        
        NSURL *url = [self tsPathForUniqueId:uniqueId url:tsUrl index:tsIndex];
        BOOL removeRet = YES;
        if ([self.fm fileExistsAtPath:url.path]) {
            removeRet = [self.fm removeItemAtURL:url error:nil];
        }
        
        if (removeRet) {
            BOOL  createRet = [data writeToURL:url options:NSDataWritingAtomic error:nil];
            if (!createRet) {
                NSLog(@"save m3u8 for url %@ failed",uniqueId);
            }
        }
    });
}

- (void)cacheTsInContainer:(NSString *)uniqueId url:(NSURL *)tsUrl index:(NSUInteger)tsIndex tempLocalUrl:(NSURL *)local;
{
    if (uniqueId.length == 0  || !local) {
        return;
    }
    
    [self validateChildContainerWithUniqueId:uniqueId];
    
    if (![self.fm fileExistsAtPath:local.path]) {
        NSLog(@"ts 不存在 %@",local.path);
        return ;
    }
    
    dispatch_sync(self.ioQueue, ^{
        [self validateChildContainerWithUniqueId:uniqueId];
        
        NSURL *targetUrl = [self tsPathForUniqueId:uniqueId url:tsUrl index:tsIndex];
        BOOL removeRet = YES;
        if ([self.fm fileExistsAtPath:targetUrl.path]) {
            removeRet = [self.fm removeItemAtURL:targetUrl error:nil];
        }
        if (removeRet) {
            NSError *error;
            BOOL ret = [self.fm moveItemAtURL:local toURL:targetUrl error:&error];
            if (!ret) {
                NSLog(@"cache ts failed %@",error);
            }else{
                NSLog(@">>>%@",targetUrl.path);
            }
        }
    });
}

- (void)removeTsInContainder:(NSString *)uniqueId url:(NSURL *)tsUrl index:(NSUInteger)tsIndex;
{
    dispatch_sync(self.ioQueue, ^{
        NSURL *url = [self tsPathForUniqueId:uniqueId url:tsUrl index:tsIndex];
        BOOL removeRet = YES;
        if ([self.fm fileExistsAtPath:url.path]) {
            removeRet = [self.fm removeItemAtURL:url error:nil];
        }
    });
}

#pragma mark - helper
- (void)makeContainerWithName:(NSString *)name
{
    NSURL *cacheFolder = [self containerPathWithName:name];
    if (!cacheFolder) {
        return;
    }
    self.containerUrl = cacheFolder;
    
    if (![self.fm fileExistsAtPath:cacheFolder.path]) {
        BOOL ret = [self.fm createDirectoryAtURL:cacheFolder withIntermediateDirectories:YES attributes:nil error:nil];
        if (ret) {
            NSLog(@"创建 containerUrl  成功");
        }
    }
}

- (NSURL *)containerPathWithName:(NSString *)name
{
    NSArray *urls = [self.fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    if (urls.count != 0) {
        NSURL *cacheFolder = [[urls firstObject] URLByAppendingPathComponent:name];
        return cacheFolder;
    }
    return nil;
}

- (NSURL *)childContainerWithUniqueId:(NSString *)uniqueId
{
    NSURL *childContainerUrl = [self.containerUrl URLByAppendingPathComponent:uniqueId];
    return childContainerUrl;
}

- (void)validateChildContainerWithUniqueId:(NSString *)uniqueId
{
    NSURL *childContainer = [self childContainerWithUniqueId:uniqueId];
    if (![self.fm fileExistsAtPath:childContainer.path]) {
        BOOL ret = [self.fm createDirectoryAtURL:childContainer withIntermediateDirectories:YES attributes:nil error:NULL];
        if (!ret) {
            NSLog(@"create child container failed");
        }
    }
}

- (NSURL *)m3u8UrlInChildContainer:(NSString *)uniqueId
{
    NSURL *childContainer = [self childContainerWithUniqueId:uniqueId];
    NSString *m3u8FileName = [NSString stringWithFormat:@"%@.m3u8",uniqueId];
    return [childContainer URLByAppendingPathComponent:m3u8FileName];
}

- (BOOL)childContainerExistForUniqueId:(NSString *)uniqueId
{
    NSArray *childContainers = [self.fm contentsOfDirectoryAtURL:self.containerUrl includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
    if ([childContainers containsObject:uniqueId]) {
        return YES;
    }
    return NO;
}

- (NSURL *)tsPathForUniqueId:(NSString *)uniqueId url:(NSURL *)tsUrl index:(NSUInteger)tsIndex
{
    NSURL *childContainerUrl = [self childContainerWithUniqueId:uniqueId];
    NSURL *url = [childContainerUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%lu.ts",(unsigned long)tsIndex]];
    return url;
}

#pragma mark - Private
- (NSString *)localServerDocu;
{
    return self.containerUrl.path;
}
@end
